console.log(self)
self.addEventListener('activate', console.log)
self.addEventListener('install', console.log)
self.addEventListener('push', event => console.log(event.data.json()))
