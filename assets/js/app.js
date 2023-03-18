// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import 'phoenix_html'
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'
import topbar from '../vendor/topbar'

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content')

let Hooks = {}

window.addEventListener(`phx:clear_number`, () => {
  console.log('Clearing Number 🔥')
  document.getElementById('user-form_number').value = ''
})

window.addEventListener(`phx:set_storage`, (e) => {
  for (const [key, value] of Object.entries(e.detail)) {
    console.log(`Saving key: ${key} and value: ${value} to localStorage 💾`)
    localStorage.setItem(key, value)
  }
})

Hooks.RestoreUser = {
  mounted() {
    console.log('Restoring user from localStorage 🥶')
    this.pushEvent('restore_user', {
      admin_token: localStorage.getItem('admin_token'),
      name: localStorage.getItem('name'),
      only_viewing: localStorage.getItem('only_viewing'),
    })
  },
}

Hooks.Copy = {
  mounted() {
    let { to } = this.el.dataset
    this.el.addEventListener('click', (ev) => {
      ev.preventDefault()
      let text = document.querySelector(to).innerText
      navigator.clipboard.writeText(text).then(() => {
        console.log('All done again!')
      })
      this.pushEvent('text_copied', { text: text })
    })
  },
}

let liveSocket = new LiveSocket('/live', Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' })
window.addEventListener('phx:page-loading-start', (info) =>
  topbar.delayedShow(200)
)
window.addEventListener('phx:page-loading-stop', (info) => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
