self.addEventListener('install', () => self.skipWaiting())

self.addEventListener('notificationclick', notificationEvent => {
    notificationEvent.notification.close()
    self.clients.openWindow(notificationEvent.notification.data.url)
})

self.addEventListener('push', pushEvent => {
    data = pushEvent.data.json()
    const title = data.title || "Spoor Kapot"
    const url = data.url || "https://www.ns.nl/reisinformatie/actuele-situatie-op-het-spoor/"

    const promise = self.registration.showNotification(title, { data: { url: url } })
    pushEvent.waitUntil(promise)
})
