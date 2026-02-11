import { invoke } from '@tauri-apps/api/core';
import { relaunch } from '@tauri-apps/plugin-process';
import { check } from '@tauri-apps/plugin-updater';
import { useEffect, useState } from 'react';
import './App.css';
import reactLogo from './assets/react.svg';

function App() {
  const [greetMsg, setGreetMsg] = useState('');
  const [name, setName] = useState('');
  const [updateStatus, setUpdateStatus] = useState<string>('');
  const [isChecking, setIsChecking] = useState(false);
  const [downloadProgress, setDownloadProgress] = useState<number>(0);

  async function greet() {
    // Learn more about Tauri commands at https://tauri.app/develop/calling-rust/
    setGreetMsg(await invoke('greet', { name }));
  }

  async function checkForUpdates() {
    setIsChecking(true);
    setUpdateStatus('Checking for updates...');

    try {
      const update = await check();

      if (update) {
        setUpdateStatus(
          `Update available: ${update.version}. Current version: ${update.currentVersion}`
        );

        // Download and install the update
        setUpdateStatus('Downloading update...');
        await update.downloadAndInstall((progress) => {
          if (progress.event === 'Started') {
            setUpdateStatus(`Downloading update: ${progress.data.contentLength} bytes`);
          } else if (progress.event === 'Progress') {
            const percentage = Math.round(
              (progress.data.chunkLength / (progress.data.contentLength || 1)) * 100
            );
            setDownloadProgress(percentage);
            setUpdateStatus(`Downloading: ${percentage}%`);
          } else if (progress.event === 'Finished') {
            setUpdateStatus('Download complete! Installing...');
          }
        });

        setUpdateStatus('Update installed! Restarting application...');

        // Relaunch the application after update
        await relaunch();
      } else {
        setUpdateStatus('You are running the latest version!');
      }
    } catch (error) {
      setUpdateStatus(`Error checking for updates: ${error}`);
      console.error('Update error:', error);
    } finally {
      setIsChecking(false);
    }
  }

  // Check for updates on mount
  useEffect(() => {
    checkForUpdates();
  }, []);

  return (
    <main className="container">
      <h1>Welcome to Tauri + React</h1>

      <div className="row">
        <a href="https://vite.dev" target="_blank">
          <img src="/vite.svg" className="logo vite" alt="Vite logo" />
        </a>
        <a href="https://tauri.app" target="_blank">
          <img src="/tauri.svg" className="logo tauri" alt="Tauri logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <p>Click on the Tauri, Vite, and React logos to learn more.</p>

      <div
        style={{
          margin: '20px 0',
          padding: '10px',
          backgroundColor: '#f0f0f0',
          borderRadius: '5px',
        }}
      >
        <h3>Auto Updater</h3>
        <p>{updateStatus}</p>
        {downloadProgress > 0 && (
          <progress value={downloadProgress} max="100" style={{ width: '100%' }} />
        )}
        <button onClick={checkForUpdates} disabled={isChecking} style={{ marginTop: '10px' }}>
          {isChecking ? 'Checking...' : 'Check for Updates'}
        </button>
      </div>

      <form
        className="row"
        onSubmit={(e) => {
          e.preventDefault();
          greet();
        }}
      >
        <input
          id="greet-input"
          onChange={(e) => setName(e.currentTarget.value)}
          placeholder="Enter a name..."
        />
        <button type="submit">Greet</button>
      </form>
      <p>{greetMsg}</p>
    </main>
  );
}

export default App;
