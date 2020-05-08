#include <avr/io.h>
#include <stdbool.h>
#include <string.h>

#include "Config/DancePadConfig.h"
#include "ConfigStore.h"
#include "Pad.h"
#include "ADC.h"

#define MIN(a,b) ((a) < (b) ? a : b)
#define MAX(a,b) ((a) > (b) ? a : b)
#define LAST_VALUES 12
#define RETRIGGER_THRESHOLD 50
#define ALLOW_TRIGGER_THRESHOLD 30

PadConfiguration PAD_CONF;

PadState PAD_STATE = { 
    .sensorValues = { [0 ... SENSOR_COUNT - 1] = 0 },
    .buttonsPressed = { [0 ... BUTTON_COUNT - 1] = false },
    .allowTriggers = { [0 ... SENSOR_COUNT - 1] = false },
    .lastValues = { [0 ... SENSOR_COUNT - 1] = { [0 ... 11] = 0 } },
    .lastValuesIndex = 0
};

typedef struct {
    uint16_t sensorReleaseThresholds[SENSOR_COUNT];
    int8_t buttonToSensorMap[BUTTON_COUNT][SENSOR_COUNT + 1];
} InternalPadConfiguration;

InternalPadConfiguration INTERNAL_PAD_CONF;

uint16_t LastAVG(uint16_t *arr, uint16_t idx, uint16_t numElements) {
    uint16_t avg = 0;
    for (int i = 0; i < numElements; i++) {
        avg += arr[(idx-i)%LAST_VALUES];
    }
    avg = avg / numElements;
    return avg;
}

void Pad_UpdateInternalConfiguration(void) {
    for (int i = 0; i < SENSOR_COUNT; i++) {
        INTERNAL_PAD_CONF.sensorReleaseThresholds[i] = PAD_CONF.sensorThresholds[i] * PAD_CONF.releaseMultiplier;
    }

    // Precalculate array for mapping buttons to sensors.
    // For every button, there is an array of sensor indices. when there are no more buttons assigned to that sensor,
    // the value is -1.
    for (int buttonIndex = 0; buttonIndex < BUTTON_COUNT; buttonIndex++) {
        int mapIndex = 0;

        for (int sensorIndex = 0; sensorIndex < SENSOR_COUNT; sensorIndex++) {
            if (PAD_CONF.sensorToButtonMapping[sensorIndex] == buttonIndex) {
                INTERNAL_PAD_CONF.buttonToSensorMap[buttonIndex][mapIndex++] = sensorIndex;
            }
        }

        // mark -1 to end
        INTERNAL_PAD_CONF.buttonToSensorMap[buttonIndex][mapIndex] = -1;
    }
}

void Pad_Initialize(const PadConfiguration* padConfiguration) {
    ADC_Init();
    Pad_UpdateConfiguration(padConfiguration);
    DDRD = 0xFF;
}

void Pad_UpdateConfiguration(const PadConfiguration* padConfiguration) {
    memcpy(&PAD_CONF, padConfiguration, sizeof (PadConfiguration));
    Pad_UpdateInternalConfiguration();
}

void Pad_UpdateState(void) {
    uint16_t newValues[SENSOR_COUNT]; 
    uint16_t lvIndex = ++PAD_STATE.lastValuesIndex % LAST_VALUES;
    
    for (int i = 0; i < SENSOR_COUNT; i++) {
        newValues[i] = ADC_Read(i);
    }
    
    for (int i = 0; i < SENSOR_COUNT; i++) {
        // TODO: weight of old value and new value is not configurable for now
        // because division by unknown value means ass performance.
        uint16_t newValue = (PAD_STATE.sensorValues[i] + newValues[i]) / 2;
        PAD_STATE.sensorValues[i] = newValue;

            // we keep track of the last 12 values for retrigger purposes uwu
        PAD_STATE.lastValues[i][lvIndex] = newValue;

            // if the previous pressure was below the trigger threshold
            // and the current pressure is above, (trigger) and set allowTriggers
            // to false
        if (PAD_STATE.sensorValues[i] < PAD_CONF.sensorThresholds[i])
            PAD_STATE.allowTriggers[i] = false;
    }

    for (int i = 0; i < BUTTON_COUNT; i++) {
        bool newButtonPressedState = false;

        for (int j = 0; j < SENSOR_COUNT; j++) {
            int8_t sensor = INTERNAL_PAD_CONF.buttonToSensorMap[i][j];

            if (sensor == -1) {
                break;
            }

            if (sensor < 0 || sensor > SENSOR_COUNT) {
                break;
            }

            uint16_t sensorVal = PAD_STATE.sensorValues[sensor];

            uint16_t threshold = PAD_CONF.sensorThresholds[sensor];
            uint16_t lavg = LastAVG(PAD_STATE.lastValues[sensor], lvIndex, LAST_VALUES);

            // DEBUG GOOD
            //PAD_STATE.sensorValues[5] = LastAVG(PAD_STATE.lastValues[sensor], lvIndex, LAST_VALUES);


            // if the sensor value is above threshold and the value is below
            // last 12 values avg + allow retrigger threshold we set allow retrigger to true
            // (foot is on panel but we're not in the middle of a step)
            //
            // if sensor is above threshold, allow retrigger is true and sensor value is above
            // retrigger threshold + 50 we unpress the button and set allow retriggers to false
            // (a step is happening so we want to unpress the panel and disable retrigger.
            // on the next polling the panel will be pressed again because the value is still 
            // over the threshold)
            if (sensorVal > threshold) {
                if (PAD_STATE.allowTriggers[sensor] == false) {
                    if (sensorVal - lavg < ALLOW_TRIGGER_THRESHOLD)
                        PAD_STATE.allowTriggers[sensor] = true;
                }
                if (PAD_STATE.allowTriggers[sensor] && sensorVal > lavg + RETRIGGER_THRESHOLD) {
                    PAD_STATE.allowTriggers[sensor] = false;
                    newButtonPressedState = false;
                    break;
                }
                newButtonPressedState = true;
                break;
            }
           /* 
            *   This block should be rewritten using the new retrigger logic
            *   
            *   As it is right now, the ReleaseThresholds are useless
            *
            *   don't @me

            if (PAD_STATE.buttonsPressed[i]) {
                if (sensorVal > INTERNAL_PAD_CONF.sensorReleaseThresholds[sensor]) {
                    newButtonPressedState = true;
                    break;
                }
            } else {
                if (sensorVal > PAD_CONF.sensorThresholds[sensor]) {
                    newButtonPressedState = true;
                    break;
                }
            }
            */
        }

        PAD_STATE.buttonsPressed[i] = newButtonPressedState;
    }
}
