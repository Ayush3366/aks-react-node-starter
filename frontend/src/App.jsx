import React, { useEffect, useState } from 'react'

export default function App() {
  const [employees, setEmployees] = useState([])
  const [name, setName] = useState('')

  const API = import.meta.env.VITE_API_URL || 'http://localhost:8080'

  async function load() {
    const r = await fetch(`${API}/api/employees`)
    const data = await r.json()
    setEmployees(data)
  }

  async function add() {
    if (!name.trim()) return
    await fetch(`${API}/api/employees`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name })
    })
    setName('')
    load()
  }

  useEffect(() => { load() }, [])

  return (
    <div className="page">
      <header className="hero">
        <h1>Ayush Employee Manager</h1>
        <p>React + Node • Smooth gradient UI • Hover effects</p>
      </header>

      <section className="card">
        <div className="row">
          <input
            placeholder="Enter employee name..."
            value={name}
            onChange={e => setName(e.target.value)}
          />
          <button onClick={add}>Add</button>
        </div>
        <ul className="list">
          {employees.map((e, i) => (
            <li key={i} className="list-item">
              <span>{e.name}</span>
            </li>
          ))}
        </ul>
      </section>

      <footer className="footer">Built by Ayush • Local dev now, AKS next 🚀</footer>
    </div>
  )
}
