import "phoenix_html"

const vapidKey = JSON.parse(document.getElementById("vapid-key").text)

function registerWorker () {
    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register('/assets/sw.js')
            .then((registration) => registration.pushManager.subscribe({userVisibleOnly: true, ...vapidKey})
                .then((subscription) => {
                    fetch("/api/register", {
                        method: "POST",
                        headers: {
                            'Content-Type': 'application/json',
                          },
                      body: JSON.stringify(subscription)
                    })
                })
            )
    }
}

document.getElementById("foo-button").addEventListener("click", registerWorker)
