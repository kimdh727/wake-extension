import * as fs from 'fs';
import * as path from 'path';
import { workspace, ExtensionContext, window, commands } from 'vscode';

import {
  LanguageClient,
  LanguageClientOptions,
  RequestType,
  ServerOptions,
  TransportKind
} from 'vscode-languageclient/node';

let client: LanguageClient;

export function activate(context: ExtensionContext) {
  // The server is implemented in node
  let serverModule = context.asAbsolutePath(path.join('server', 'out', 'server.js'));
  // The debug options for the server
  // --inspect=6009: runs the server in Node's Inspector mode so VS Code can attach to the server for debugging
  let debugOptions = { execArgv: ['--nolazy', '--inspect=6009'] };

  commands.registerCommand('wakeExtension.wakePath', setWakePath)

  // If the extension is launched in debug mode then the debug server options are used
  // Otherwise the run options are used
  let serverOptions: ServerOptions = {
    run: { module: serverModule, transport: TransportKind.ipc },
    debug: {
      module: serverModule,
      transport: TransportKind.ipc,
      options: debugOptions
    }
  };

  // Options to control the language client
  let clientOptions: LanguageClientOptions = {
    // Register the server for plain text documents
    documentSelector: [{ scheme: 'file', language: 'wake' }],
    synchronize: {
      // Notify the server about file changes to '.clientrc files contained in the workspace
      fileEvents: workspace.createFileSystemWatcher('**/.clientrc')
    }
  };

  // Create the language client and start the client.
  client = new LanguageClient(
    'wakeExtension',
    'Wake Extension',
    serverOptions,
    clientOptions
  );

  // Start the client. This will also launch the server
  client.start();

  // TODO
  // client.onReady().then ((value) => {
  //   client.onRequest('wakePath', (handler) => {
  //     return wakePathInputBox(value);
  //   })
  // })
}

export function deactivate(): Thenable<void> | undefined {
  if (!client) {
    return undefined;
  }
  return client.stop();
}

async function wakePathInputBox(defpath?: string): Promise<string|undefined> {

  defpath ? defpath : defpath = '/usr/local/bin';
  let result: string;

  await window.showInputBox({title: 'wake path', value: defpath, placeHolder: 'enter wake path', ignoreFocusOut: true}).then(
    value => {
      const stat = fs.lstatSync(value);
      if (stat.isDirectory()) result = value + '/wake';
      else if (stat.isFile()) result = value;
      else console.error('Invalid Input');
    }
  )

  return result;
}

async function setWakePath() {

  client.sendRequest(new RequestType('wakePath'), await wakePathInputBox())
}


workspace.onDidChangeConfiguration(listener => {

  const configs = workspace.getConfiguration("wake-extension");

  let wakePath: string = configs.get("wake-path")
  if (wakePath) {
    const wakePathStat = fs.lstatSync(wakePath);

    if (wakePathStat.isDirectory()) wakePath = wakePath + '/wake';
    else if (wakePathStat.isFile()) wakePath = wakePath;
    else console.error('Invalid Input');

    client.sendRequest(new RequestType('wakePath'), wakePath);
  }
})
