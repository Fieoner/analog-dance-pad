import * as HID from 'node-hid'
import { KNOWN_DEVICES } from '../Teensy2DeviceDriver'
import { ReportID } from '../Teensy2Reports'

console.log('Setting Teensy devices to program mode...')

HID.devices().forEach(device => {
  // only known devices
  if (!KNOWN_DEVICES.some(d => d.vendorId === device.vendorId && d.productId === device.productId)) {
    return
  }

  if (device.path) {
    console.log('Trying to reset', device.path)
    const hidDevice = new HID.HID(device.path)
    try {
      hidDevice.write([ReportID.RESET, 0x00])
    } catch (e) {
      // error is expected because the device will boot upon write above, and
      // it probably happens too fast to node-hid's liking.
    }
  }
})

console.log('Done!')
