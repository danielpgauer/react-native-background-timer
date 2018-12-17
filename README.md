# React Native Background Timer
Emit event periodically (even when app is in the background).

## Installation

:warning: If you use [create-react-native-app](https://github.com/react-community/create-react-native-app) you must [eject](https://github.com/react-community/create-react-native-app/blob/master/EJECTING.md) it before running `react-native link`.

- `yarn add react-native-bg-timer`
- `react-native link`

### Installation using CocoaPods on iOS
- `yarn add react-native-bg-timer`
- add the following to your Podfile: `pod 'react-native-bg-timer', :path => '../node_modules/react-native-bg-timer'`

## Usage Crossplatform
To use the same code both on Android and iOS use runBgTimer() and stopBgTimer(). There can be used only one background timer to keep code consistent.

```javascript
BgTimer.runBgTimer(() => { 
//code that will be called every 3 seconds 
}, 
3000);
//rest of code will be performing for iOS on background too

BgTimer.stopBgTimer(); //after this call all code on background stop run.
```
> Android didn't tested as well.

## Usage iOS
After iOS update logic of background task little bit changed. So we can't use as it was. 
You have to use only start() and stop() without parameters. And all code that is performing will continue performing on background including all setTimeout() timers.

Example:
```javascript
BgTimer.start();
// Do whatever you want incuding setTimeout;
BgTimer.stop();
```

> If you call stop() on background no new tasks will be started!
> Don't call .start() twice, as it stop performing previous background task and starts new. 
> If it will be called on backgound no tasks will run.

## Usage Android
You can use the `setInterval` and `setTimeout` functions.
This API is identical to that of `react-native` and can be used to quickly replace existing timers
with background timers.

```javascript
import BgTimer from 'react-native-bg-timer';
```

```javascript
// Start a timer that runs continuous after X milliseconds
const intervalId = BgTimer.setInterval(() => {
	// this will be executed every 200 ms
	// even when app is the the background
	console.log('tic');
}, 200);

// Cancel the timer when you are done with it
BgTimer.clearInterval(intervalId);
```

```javascript
// Start a timer that runs once after X milliseconds
const timeoutId = BgTimer.setTimeout(() => {
	// this will be executed once after 10 seconds
	// even when app is the the background
  	console.log('tac');
}, 10000);

// Cancel the timeout if necessary
BgTimer.clearTimeout(timeoutId);
```

### Obsolete
Obsolete usage which doesn't allows to use multiple background timers.

```js
import {
  DeviceEventEmitter,
  NativeAppEventEmitter,
  Platform,
} from 'react-native';

import BgTimer from 'react-native-bg-timer';
```

```js
const EventEmitter = Platform.select({
  ios: () => NativeAppEventEmitter,
  android: () => DeviceEventEmitter,
})();
```

```js
// start a global timer
BgTimer.start(5000); // delay in milliseconds only for Android
```
```js
// listen for event
EventEmitter.addListener('bgTimer', () => {
	// this will be executed once after 5 seconds
	console.log('toe');
});
```
```js
// stop the timer
BgTimer.stop();
```
