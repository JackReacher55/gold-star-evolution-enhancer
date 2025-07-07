import { useState, useRef } from 'react';
import Head from 'next/head';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

export default function Home() {
  const [file, setFile] = useState(null);
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [downloadUrl, setDownloadUrl] = useState('');
  const [audioAnalysis, setAudioAnalysis] = useState(null);
  const [audioFixUrl, setAudioFixUrl] = useState('');
  const [alert, setAlert] = useState('');
  const [selectedResolution, setSelectedResolution] = useState('1920:1080');
  const [videoPreview, setVideoPreview] = useState('');
  const [analyzingAudio, setAnalyzingAudio] = useState(false);
  const fileInputRef = useRef(null);

  const resolutions = [
    { label: 'HD (720p)', value: '1280:720' },
    { label: 'Full HD (1080p)', value: '1920:1080' },
    { label: '2K (1440p)', value: '2560:1440' },
    { label: '4K (2160p)', value: '3840:2160' }
  ];

  const handleFileChange = (e) => {
    const selectedFile = e.target.files[0];
    if (selectedFile) {
      setFile(selectedFile);
      setDownloadUrl('');
      setAudioAnalysis(null);
      setAudioFixUrl('');
      setAlert('');
      setProgress(0);
      const url = URL.createObjectURL(selectedFile);
      setVideoPreview(url);
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    const droppedFile = e.dataTransfer.files[0];
    if (droppedFile && droppedFile.type.startsWith('video/')) {
      setFile(droppedFile);
      setDownloadUrl('');
      setAudioAnalysis(null);
      setAudioFixUrl('');
      setAlert('');
      setProgress(0);
      const url = URL.createObjectURL(droppedFile);
      setVideoPreview(url);
    }
  };

  const handleDragOver = (e) => {
    e.preventDefault();
  };

  const handleUpload = async () => {
    if (!file) return;
    setUploading(true);
    setAlert('');
    setProgress(0);
    const formData = new FormData();
    formData.append('file', file);
    formData.append('resolution', selectedResolution);
    try {
      const progressInterval = setInterval(() => {
        setProgress(prev => {
          if (prev >= 90) {
            clearInterval(progressInterval);
            return 90;
          }
          return prev + 10;
        });
      }, 500);
      
      const res = await fetch(`${API_BASE_URL}/upload`, {
        method: 'POST',
        body: formData,
      });
      
      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || `Upload failed with status ${res.status}`);
      }
      
      const data = await res.json();
      setProgress(100);
      setDownloadUrl(data.download_url);
      setAudioAnalysis(data.analysis);
      setAlert(`Success! Video upscaled to ${data.resolution} with ${data.scale}x enhancement.`);
      clearInterval(progressInterval);
    } catch (error) {
      setAlert(`Error uploading video: ${error.message}. Please try again.`);
      console.error('Upload error:', error);
    } finally {
      setUploading(false);
    }
  };

  const handleAnalyzeAudio = async () => {
    if (!file) return;
    setAnalyzingAudio(true);
    setAlert('');
    setAudioAnalysis(null);
    const formData = new FormData();
    formData.append('file', file);
    try {
      const res = await fetch(`${API_BASE_URL}/fix-audio`, {
        method: 'POST',
        body: formData,
      });
      
      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || `Audio analysis failed with status ${res.status}`);
      }
      
      const data = await res.json();
      setAudioAnalysis(data.analysis);
      setAudioFixUrl(data.download_url);
      setAlert('Audio analysis complete! Enhanced video with audio fixes available for download.');
    } catch (error) {
      setAlert(`Error analyzing audio: ${error.message}. Please try again.`);
      console.error('Audio analysis error:', error);
    } finally {
      setAnalyzingAudio(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-900 text-white flex flex-col items-center justify-center py-8">
      <Head>
        <title>Gold Star Evolution Enhancer</title>
        <meta name="description" content="AI-powered video upscaling and audio analysis" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <div className="flex flex-col md:flex-row w-full max-w-6xl gap-8">
        {/* Left: Upload Card */}
        <div className="flex-1 flex flex-col items-center justify-center">
          <div
            className="bg-gray-800 rounded-xl shadow-lg p-8 w-full max-w-md border-2 border-dashed border-indigo-400 flex flex-col items-center justify-center"
            onDrop={handleDrop}
            onDragOver={handleDragOver}
          >
            <div className="text-lg font-semibold mb-4 text-center">Drag & drop an video here</div>
            <button
              onClick={() => fileInputRef.current?.click()}
              className="bg-indigo-500 hover:bg-indigo-600 text-white font-bold py-2 px-6 rounded mb-4 focus:outline-none focus:ring-2 focus:ring-indigo-400"
            >
              Choose File
            </button>
            <input
              ref={fileInputRef}
              type="file"
              accept="video/*"
              onChange={handleFileChange}
              className="hidden"
            />
            {file && (
              <div className="mt-2 text-sm text-gray-300">{file.name}</div>
            )}
          </div>
          {/* Resolution Dropdown */}
          <div className="w-full max-w-md mt-6">
            <label className="block text-sm font-medium text-gray-300 mb-2">Select Output Resolution:</label>
            <select
              value={selectedResolution}
              onChange={e => setSelectedResolution(e.target.value)}
              className="w-full bg-gray-800 border border-gray-700 rounded px-4 py-2 text-white focus:outline-none focus:ring-2 focus:ring-indigo-400"
            >
              {resolutions.map((res) => (
                <option key={res.value} value={res.value}>{res.label}</option>
              ))}
            </select>
          </div>
          {/* Upload Button */}
          <div className="w-full max-w-md mt-6 flex flex-col gap-4">
            <button
              onClick={handleUpload}
              disabled={uploading || !file}
              className="w-full bg-green-500 hover:bg-green-600 text-white font-bold py-2 px-6 rounded focus:outline-none focus:ring-2 focus:ring-green-400 disabled:opacity-50"
            >
              {uploading ? 'Processing...' : 'Upload & Convert'}
            </button>
            <button
              onClick={handleAnalyzeAudio}
              disabled={analyzingAudio || !file}
              className="w-full bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-6 rounded focus:outline-none focus:ring-2 focus:ring-blue-400 disabled:opacity-50"
            >
              {analyzingAudio ? 'Analyzing Audio...' : 'Analyze Audio'}
            </button>
          </div>
          {/* Progress Bar */}
          {uploading && (
            <div className="w-full max-w-md mt-4">
              <div className="h-2 bg-gray-700 rounded-full overflow-hidden">
                <div
                  className="bg-green-500 h-2 rounded-full transition-all duration-300"
                  style={{ width: `${progress}%` }}
                ></div>
              </div>
              <div className="text-xs text-gray-400 mt-1">{progress}%</div>
            </div>
          )}
          {/* Download Link */}
          {downloadUrl && (
            <div className="w-full max-w-md mt-4">
              <a
                href={downloadUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="block bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-6 rounded text-center mt-2"
              >
                Download Enhanced Video
              </a>
            </div>
          )}
          {/* Audio Fix Download Link */}
          {audioFixUrl && (
            <div className="w-full max-w-md mt-4">
              <a
                href={audioFixUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="block bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-6 rounded text-center mt-2"
              >
                Download Audio-Fixed Video
              </a>
            </div>
          )}
          {/* Audio Analysis Result */}
          {audioAnalysis && (
            <div className="w-full max-w-md mt-4 bg-gray-800 rounded p-4 border border-blue-500">
              <div className="font-semibold text-blue-300 mb-2">Audio Analysis</div>
              <div className="text-sm text-gray-200">
                <p><strong>Has Audio:</strong> {audioAnalysis.has_audio ? 'Yes' : 'No'}</p>
                {audioAnalysis.audio_codec && (
                  <p><strong>Audio Codec:</strong> {audioAnalysis.audio_codec}</p>
                )}
              </div>
            </div>
          )}
          {/* Alert Messages */}
          {alert && (
            <div className="w-full max-w-md mt-4 bg-red-800 rounded p-4 border border-red-500">
              <p className="text-red-200">{alert}</p>
            </div>
          )}
        </div>
        {/* Right: Info Card */}
        <div className="flex-1 flex flex-col justify-center items-center">
          <div className="bg-gray-800 rounded-xl shadow-lg p-8 w-full max-w-md flex flex-col gap-4">
            <div className="text-2xl font-bold mb-2 text-white">What's Gold Star Evolution Enhancer?</div>
            <div className="text-gray-300 mb-4">
              Our AI algorithm, trained by a large amount of data, can losslessly enlarge and restore the details of all kinds of blurred and unclear videos.
            </div>
            <div className="text-lg font-semibold text-white mb-2">Privacy and security</div>
            <div className="text-gray-400 mb-4">
              Relevant calculations are only carried out locally to protect your privacy from disclosure.
            </div>
            <div className="flex gap-4">
              <div className="w-24 h-16 bg-gray-700 rounded flex items-center justify-center text-gray-500">Sample 1</div>
              <div className="w-24 h-16 bg-gray-700 rounded flex items-center justify-center text-gray-500">Sample 2</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
} 