import {
  DeviceEventEmitter,
  NativeAppEventEmitter,
  NativeEventEmitter,
  NativeModules,
  Platform,
} from 'react-native';

const { RNBgTimer } = NativeModules;
const Emitter = new NativeEventEmitter(RNBgTimer);

class BgTimer {
  constructor() {
    this.uniqueId = 0;
    this.callbacks = {};

    Emitter.addListener('bgTimer.timeout', (id) => {
      if (this.callbacks[id]) {
        const callbackById = this.callbacks[id];
        const { callback } = callbackById;
        if (!this.callbacks[id].interval) {
          delete this.callbacks[id];
        } else {
          RNBgTimer.setTimeout(id, this.callbacks[id].timeout);
        }
        callback();
      }
    });
  }

  // Original API
  start(delay = 0) {
    return RNBgTimer.start(delay);
  }

  stop() {
    return RNBgTimer.stop();
  }

  runBgTimer(callback, delay) {
    const EventEmitter = Platform.select({
      ios: () => NativeAppEventEmitter,
      android: () => DeviceEventEmitter,
    })();
    this.start(0);
    this.backgroundListener = EventEmitter.addListener('bgTimer', () => {
      this.backgroundListener.remove();
      this.backgroundClockMethod(callback, delay);
    });
  }

  backgroundClockMethod(callback, delay) {
    this.bgTimer = this.setTimeout(() => {
      callback();
      this.backgroundClockMethod(callback, delay);
    },
    delay);
  }

  stopBgTimer() {
    this.stop();
    this.clearTimeout(this.bgTimer);
  }

  // New API, allowing for multiple timers
  setTimeout(callback, timeout) {
    this.uniqueId += 1;
    const timeoutId = this.uniqueId;
    this.callbacks[timeoutId] = {
      callback,
      interval: false,
      timeout,
    };
    RNBgTimer.setTimeout(timeoutId, timeout);
    return timeoutId;
  }

  clearTimeout(timeoutId) {
    if (this.callbacks[timeoutId]) {
      delete this.callbacks[timeoutId];
      // RNBgTimer.clearTimeout(timeoutId);
    }
  }

  setInterval(callback, timeout) {
    this.uniqueId += 1;
    const intervalId = this.uniqueId;
    this.callbacks[intervalId] = {
      callback,
      interval: true,
      timeout,
    };
    RNBgTimer.setTimeout(intervalId, timeout);
    return intervalId;
  }

  clearInterval(intervalId) {
    if (this.callbacks[intervalId]) {
      delete this.callbacks[intervalId];
      // RNBgTimer.clearTimeout(intervalId);
    }
  }
}

export default new BgTimer();
