const os = require('os');
const express = require('express');
const morgan = require('morgan');
const concat = require('concat-stream');
const jwt = require('jsonwebtoken');

let app = express();

app.set('json spaces', 2);

app.use(morgan('combined'));

app.use((req, res, next) => {
  req.pipe(concat(data => {
    req.body = data.toString('utf8');
    next();
  }));
});

app.all('*', (req, res) => {
  const echo = {
    path: req.path,
    headers: req.headers,
    method: req.method,
    body: req.body,
    cookies: req.cookies,
    fresh: req.fresh,
    hostname: req.hostname,
    ip: req.ip,
    ips: req.ips,
    protocol: req.protocol,
    query: req.query,
    subdomains: req.subdomains,
    xhr: req.xhr,
    os: {
      hostname: os.hostname()
    }
  };
  if (process.env.JWT_HEADER) {
    const token = req.headers[process.env.JWT_HEADER.toLowerCase()];
    if (!token) {
      echo.jwt = token;
    } else {
      const decoded = jwt.decode(token, { complete: true });
      echo.jwt = decoded;
    }
  }
  res.json(echo);
});

const server = app.listen(process.env.PORT || 80);
let calledClose = false;

process.on('exit', () => {
  if (calledClose) return;
  console.log('Got exit event. Trying to stop Express server.');
  server.close(() => console.log("Express server closed"));
});

process.on('SIGINT', () => {
  console.log('Got SIGINT. Trying to exit gracefully.');
  calledClose = true;
  server.close(() => {
    console.log("Exoress server closed. Asking process to exit.");
    process.exit();
  });
});
