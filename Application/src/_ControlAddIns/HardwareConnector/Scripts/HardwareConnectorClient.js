class AckMessage {
  constructor(e, t) {
    (this.Type = "Acknowledgement"), (this.Id = e), (this.AcknowledgeId = t);
  }
}
class CloseInfo {
  constructor(e) {
    (this.Code = e.code), (this.Reason = e.reason), (this.Error = !e.wasClean);
  }
  getReason() {
    return `${this.Error ? "error" : "reason"} (${this.Code}) ${this.Reason}`;
  }
}
class HandlerMessage {
  constructor(e, t, s, n) {
    (this.Type = "Handler"),
      (this.Id = e),
      (this.Context = t),
      (this.Handler = s),
      (this.HandlerContent = n);
  }
}
class HardwareConnector {
  constructor() {
    this.setupObject();
  }
  async sendRequestAndWaitForResponseAsync(e, t) {
    let s = new HandlerMessage(
      ++this.lastMessageIdSend,
      this.generateContextID(),
      e,
      t
    );
    this.socket.readyState !== this.socket.OPEN &&
      (await this.socketConnectionDoneAsync());
    let n = this.waitForFirstResponse(s),
      o = this.sendRequestAndWaitForAckAsync(s);
    return (await Promise.all([o, n]))[1].HandlerContent;
  }
  async sendRequestAsync(e, t, s) {
    let n = new HandlerMessage(++this.lastMessageIdSend, s, e, t);
    return (
      this.socket.readyState !== this.socket.OPEN &&
        (await this.socketConnectionDoneAsync()),
      await this.sendRequestAndWaitForAckAsync(n)
    );
  }
  registerResponseHandler(e) {
    let t = this.generateContextID();
    return this.responseCallbacks.push(new ResponseCallback(t, e)), t;
  }
  unregisterResponseHandler(e) {
    this.responseCallbacks = this.responseCallbacks.filter(
      (t) => t.context !== e
    );
  }
  getSocketState() {
    return this.socket.readyState;
  }
  getSocketClosedError() {
    return new Error(
      `[HardwareConnector] Socket is closed with ${this.closeInfo.getReason()}`
    );
  }
  async socketConnectionDoneAsync() {
    return new Promise((e, t) => {
      switch (this.socket.readyState) {
        case this.socket.OPEN:
          return void e();
        case this.socket.CLOSED:
          return void t(this.getSocketClosedError());
        case this.socket.CLOSING:
          return void t(
            new Error(
              "[HardwareConnector] Socket is closing, connection is not possible."
            )
          );
      }
      this.socket.addEventListener("close", () =>
        t(this.getSocketClosedError())
      ),
        this.socket.addEventListener("open", () => e());
    });
  }
  async sendRequestAndWaitForAckAsync(e) {
    return new Promise((t, s) => {
      this.socket.addEventListener("close", (e) => {
        clearInterval(o), s(e);
      }),
        this.socket.addEventListener("message", (s) => {
          let n = JSON.parse(s.data);
          "Acknowledgement" === n.Type &&
            n.AcknowledgeId === e.Id &&
            (clearInterval(o), t());
        });
      let n = JSON.stringify(e),
        o = setInterval(() => {
          this.socket.send(n),
            console.log("[HardwareConnector] Data sent to localhost: " + n);
        }, 100);
    });
  }
  async waitForFirstResponse(e) {
    return new Promise((t, s) => {
      this.socket.addEventListener("close", (e) => s(e)),
        this.socket.addEventListener("message", (s) => {
          let n = JSON.parse(s.data);
          "Handler" === n.Type && n.Context === e.Context && t(n);
        });
    });
  }
  handleMessage(e) {
    console.log(`[HardwareConnector] Data received from localhost: ${e.data}`);
    let t = JSON.parse(e.data);
    if ("Handler" === t.Type) {
      let e = JSON.stringify(new AckMessage(++this.lastMessageIdSend, t.Id));
      this.socket.send(e),
        console.log("[HardwareConnector] Data sent to localhost: " + e),
        this.responseCallbacks
          .filter((e) => e.context === t.Context && e.lastId < t.Id)
          .forEach((e) => {
            (e.lastId = t.Id),
              console.log(
                "[HardwareConnector] Invoking registered response handler for context: " +
                  t.Context
              ),
              e.callback(t.HandlerContent);
          });
    }
  }
  handleClose(e) {
    (this.closeInfo = new CloseInfo(e)),
      e.wasClean
        ? console.log(
            `[HardwareConnector] Connection with localhost closed, code=${e.code} reason=${e.reason}`
          )
        : console.log(
            "[HardwareConnector] Connection with localhost died unexpectedly"
          );
  }
  generateContextID() {
    return crypto.getRandomValues(new Uint32Array(4)).join("");
  }
  setupObject() {
    (this.lastMessageIdSend = 0),
      (this.responseCallbacks = []),
      (this.socket = new WebSocket("ws://127.0.0.1:60992")),
      this.socket.addEventListener("open", () =>
        console.log("[HardwareConnector] Connection established with localhost")
      ),
      this.socket.addEventListener("error", (e) =>
        console.log(`[HardwareConnector] Error: ${e}`)
      ),
      this.socket.addEventListener("message", (e) => this.handleMessage(e)),
      this.socket.addEventListener("close", (e) => this.handleClose(e));
  }
}
class ResponseCallback {
  constructor(e, t) {
    (this.lastId = 0), (this.context = e), (this.callback = t);
  }
}
window._np_hardware_connector
  ? window._np_hardware_connector.getSocketState() > 1 &&
    (window._np_hardware_connector = new HardwareConnector())
  : (window._np_hardware_connector = new HardwareConnector());
