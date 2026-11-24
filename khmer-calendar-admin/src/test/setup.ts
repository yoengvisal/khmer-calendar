import '@testing-library/jest-dom/vitest'
import { cleanup } from '@testing-library/react'
import { afterEach } from 'vitest'

/**
 * Node >= 25 ships an experimental global `localStorage` that, without `--localstorage-file`,
 * is a stub lacking the Storage methods and shadows jsdom's implementation. Install a small
 * in-memory Storage when that happens so tests behave the same on every supported Node version.
 */
function ensureWorkingLocalStorage() {
  const current = (() => {
    try {
      return window.localStorage
    } catch {
      return undefined
    }
  })()
  if (current && typeof current.getItem === 'function' && typeof current.clear === 'function') return

  const data = new Map<string, string>()
  const storage: Storage = {
    get length() {
      return data.size
    },
    clear: () => data.clear(),
    getItem: (key) => data.get(key) ?? null,
    key: (index) => [...data.keys()][index] ?? null,
    removeItem: (key) => void data.delete(key),
    setItem: (key, value) => void data.set(key, String(value)),
  }
  Object.defineProperty(window, 'localStorage', { value: storage, configurable: true })
  Object.defineProperty(globalThis, 'localStorage', { value: storage, configurable: true })
}

ensureWorkingLocalStorage()

afterEach(() => {
  cleanup()
  window.localStorage.clear()
})
