import "phoenix_html"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } })

liveSocket.connect()

const vapidKey = JSON.parse(document.getElementById("vapid-key").text)

function registerWorker(stations) {
    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.ready.then(registration => {
            registration.pushManager.subscribe({ userVisibleOnly: true, ...vapidKey })
                .then((subscription) => {
                    fetch("/api/register", {
                        method: "POST",
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify({
                            subscription: subscription,
                            stations: stations
                        })
                    })
                    document.getElementById("confirm-modal").checked = true
                }).catch((error) => alert(error.message))
        })

        navigator.serviceWorker.register('/assets/sw.js', { scope: "../" })
    }
}

window.addEventListener("phx:register", e => registerWorker(e.detail.stations))
window.addEventListener("phx:scroll_into_view", e => document.getElementById(e.detail.id).scrollIntoView({ block: "nearest" }))
