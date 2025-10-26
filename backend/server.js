import express from 'express'
import cors from 'cors'

const app = express()
app.use(cors())
app.use(express.json())

let employees = [{ name: 'Ayush' }, { name: 'Binny' }]

app.get('/api/health', (req, res) => res.json({ ok: true }))
app.get('/api/employees', (req, res) => res.json(employees))
app.post('/api/employees', (req, res) => {
  const { name } = req.body
  if (!name) return res.status(400).json({ error: 'name required' })
  employees.push({ name })
  res.status(201).json({ ok: true })
})

const port = process.env.PORT || 8080
app.listen(port, () => console.log(`API running on :${port}`))
