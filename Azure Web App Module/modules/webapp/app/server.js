const http = require('http');

const port = process.env.PORT || 8080;
const host = '0.0.0.0';

const requestListener = (req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello from Azure Web App deployed with Terraform!\n');
};

const server = http.createServer(requestListener);
server.listen(port, host, () => {
  console.log(`Server running at http://${host}:${port}/`);
});