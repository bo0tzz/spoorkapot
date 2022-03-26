import "phoenix_html"

const vapidKey = JSON.parse(document.getElementById("vapid-key").text)

function registerWorker () {
    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.ready.then(registration => {
            registration.pushManager.subscribe({userVisibleOnly: true, ...vapidKey})
                .then((subscription) => {
                    fetch("/api/register", {
                        method: "POST",
                        headers: {
                            'Content-Type': 'application/json',
                          },
                      body: JSON.stringify(subscription)
                    })
                })
        })

        navigator.serviceWorker.register('/assets/sw.js', {scope: "../"}).then(console.log)
    }
}

document.getElementById("foo-button").addEventListener("click", registerWorker)
