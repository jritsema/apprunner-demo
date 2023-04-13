const app = require("express")()
const path = require("path")

app.get("/health", (req, res) => {
  res.send("healthy \n")
})

app.get("/", (req, res) => {
  console.log("GET /index.html");
  res.sendFile(path.join(__dirname, "/index.html"));
})

const port = process.env.PORT || 8080
const server = app.listen(port, () => {
  console.log("listening on http://localhost:%s", port)
})

process.on("SIGTERM", () => {
  console.log("SIGTERM signal received: closing HTTP server")
  server.close(() => {
    console.log("HTTP server closed")
  })
})