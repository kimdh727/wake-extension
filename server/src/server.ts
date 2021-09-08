import {
	createConnection,
	TextDocuments,
	ProposedFeatures,
	InitializeParams,
	TextDocumentSyncKind,
	InitializeResult
} from 'vscode-languageserver/node';

import {
	TextDocument
} from 'vscode-languageserver-textdocument';
import {
	WakeDocument,
	runWakeHtml,
	htmlToWakeDocument,
	getWakePath,
	setWakePath,
	wakedoc,
	parseWake
} from './wake'
import { definitionHandler } from './definition'
import { hoverHandler } from './hover';
import { WorkspaceFoldersFeature } from 'vscode-languageserver/lib/common/workspaceFolders';

// Create a connection for the server, using Node's IPC as a transport.
// Also include all preview / proposed LSP features.
let connection = createConnection(ProposedFeatures.all);

// Create a simple text document manager.
let documents: TextDocuments<TextDocument> = new TextDocuments(TextDocument);

let hasConfigurationCapability: boolean = false;
let hasWorkspaceFolderCapability: boolean = false;

connection.onInitialize((params: InitializeParams) => {

	let capabilities = params.capabilities;

	hasConfigurationCapability = !!(
		capabilities.workspace && !!capabilities.workspace.configuration
	);
	hasWorkspaceFolderCapability = !!(
		capabilities.workspace && !!capabilities.workspace.workspaceFolders
	);

	const result: InitializeResult = {
		capabilities: {
			textDocumentSync: TextDocumentSyncKind.Incremental,
			definitionProvider: true,
			hoverProvider: true
		}
	};

	if (hasWorkspaceFolderCapability) {
		result.capabilities.workspace = {
			workspaceFolders: {
				supported: true
			}
		};
	}
	return result;
});

connection.onInitialized(() => {

	if (hasConfigurationCapability) {
		const configs = connection.workspace.getConfiguration("wake-extension")

		configs.then(value => {
			let wakePath = value['wake-path'];
			if (wakePath != "") setWakePath(wakePath);
			else getWakePath();
		})
	} else {
		getWakePath();
	}

	if (hasWorkspaceFolderCapability) {
		connection.workspace.onDidChangeWorkspaceFolders(_event => {
			connection.console.log('Workspace folder change event received.');
		});
	}
});

connection.onDidChangeWatchedFiles(_change => {
	// Monitored files have change in VSCode
	connection.console.log('We received an file change event');
});

// TODO: Async ??
documents.onDidOpen ((e) => {
	// parseWake();
})

documents.onDidSave((e) => {
	parseWake();
})

connection.onDefinition(handler => {
	return definitionHandler(handler, wakedoc);
})

connection.onHover(handler => {
	return hoverHandler(handler, wakedoc);
})

connection.onRequest('wakePath', (handler: string) => {
	setWakePath(handler);
})

// Make the text document manager listen on the connection
// for open, change and close text document events
documents.listen(connection);

// Listen on the connection
connection.listen();

// TODO
// connection.sendRequest(new RequestType('wakePath'), 'abc').then((value) => {
// 	console.log(value);
// })
