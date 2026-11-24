import '@fontsource/noto-sans-khmer/khmer-400.css'
import '@fontsource/noto-sans-khmer/khmer-500.css'
import '@fontsource/noto-sans-khmer/khmer-600.css'
import './app/styles/tokens.css'
import './app/styles/global.css'
import './shared/ui/ui.css'

import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'

const root = createRoot(document.getElementById('root')!)

// Load the app lazily so a configuration error (thrown while evaluating app/config.ts)
// is shown on screen instead of a blank page.
import('./app/App')
  .then(({ App }) => {
    root.render(
      <StrictMode>
        <App />
      </StrictMode>,
    )
  })
  .catch((error: unknown) => {
    console.error(error)
    const message = error instanceof Error ? error.message : String(error)
    root.render(
      <main className="page" style={{ padding: 'var(--space-8) var(--space-4)' }}>
        <div className="state state--error" role="alert">
          <p className="state__title">The admin app failed to start</p>
          <p className="state__description">
            <code>{message}</code>
          </p>
        </div>
      </main>,
    )
  })
