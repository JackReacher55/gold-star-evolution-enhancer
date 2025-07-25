import { useState, useRef } from 'react';
import Head from 'next/head';

// API configuration
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
      
      // Create video preview
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
      // Simulate progress
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
        throw new Error('Upload failed');
      }

      const data = await res.json();
      setProgress(100);
      setDownloadUrl(data.download_url);
      setAudioAnalysis(data.analysis);
      
      if (data.analysis) {
        if (!data.analysis.has_audio) {
          setAlert('No audio detected. You can fix this by adding a silent track.');
        } else {
          setAlert(`Audio detected: ${data.analysis.audio_codec}`);
        }
      }
      
      clearInterval(progressInterval);
    } catch (error) {
      setAlert('Error uploading video. Please try again.');
      console.error('Upload error:', error);
    } finally {
      setUploading(false);
    }
  };

  const handleFixAudio = async () => {
    if (!file) return;
    
    setUploading(true);
    setAlert('');
    
    const formData = new FormData();
    formData.append('file', file);
    
    try {
      const res = await fetch(`${API_BASE_URL}/fix-audio`, {
        method: 'POST',
        body: formData,
      });
      
      if (!res.ok) {
        throw new Error('Audio fix failed');
      }
      
      const data = await res.json();
      setAudioFixUrl(data.download_url);
      setAlert('Audio fixed successfully! Download the new video below.');
    } catch (error) {
      setAlert('Error fixing audio. Please try again.');
      console.error('Audio fix error:', error);
    } finally {
      setUploading(false);
    }
  };

  const formatFileSize = (bytes) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-yellow-50 via-orange-50 to-red-50">
      <Head>
        <title>Gold Star Evolution Enhancer - AI-Powered Video Upscaling</title>
        <meta name="description" content="Transform your videos to HD, 2K, or 4K quality with our AI-powered video upscaler. Gold Star Evolution Enhancer - Professional video enhancement." />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <div className="container mx-auto px-4 py-8">
        <div className="text-center mb-8">
          <div className="flex justify-center items-center mb-4">
            <span className="text-6xl mr-4">🌟</span>
            <h1 className="text-5xl font-bold text-gray-800 mb-2">
              Gold Star Evolution Enhancer
            </h1>
            <span className="text-6xl ml-4">⭐</span>
          </div>
          <p className="text-xl text-gray-600">
            Transform your videos to HD, 2K, or 4K quality with AI-powered upscaling
          </p>
          <p className="text-sm text-gray-500 mt-2">
            Professional video enhancement powered by advanced AI technology
          </p>
        </div>

        <div className="max-w-4xl mx-auto">
          {/* File Upload Section */}
          <div className="bg-white rounded-lg shadow-lg p-6 mb-6 border-2 border-yellow-200">
            <div
              className={`border-2 border-dashed rounded-lg p-8 text-center transition-colors ${
                file ? 'border-green-400 bg-green-50' : 'border-yellow-300 hover:border-yellow-400'
              }`}
              onDrop={handleDrop}
              onDragOver={handleDragOver}
            >
              {!file ? (
                <div>
                  <div className="text-6xl mb-4">🎬</div>
                  <p className="text-lg text-gray-600 mb-2">
                    Drop your video here or click to browse
                  </p>
                  <p className="text-sm text-gray-500 mb-4">
                    Supports MP4, AVI, MOV, and other video formats
                  </p>
                  <button
                    onClick={() => fileInputRef.current?.click()}
                    className="bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-yellow-600 hover:to-orange-600 text-white px-6 py-2 rounded-lg transition-colors font-semibold"
                  >
                    Choose Video File
                  </button>
                </div>
              ) : (
                <div>
                  <div className="text-4xl mb-4">✅</div>
                  <p className="text-lg font-semibold text-gray-800 mb-2">
                    {file.name}
                  </p>
                  <p className="text-sm text-gray-600 mb-4">
                    Size: {formatFileSize(file.size)}
                  </p>
                  <button
                    onClick={() => fileInputRef.current?.click()}
                    className="text-yellow-600 hover:text-yellow-700 underline"
                  >
                    Choose different file
                  </button>
                </div>
              )}
              
              <input
                ref={fileInputRef}
                type="file"
                accept="video/*"
                onChange={handleFileChange}
                className="hidden"
              />
            </div>

            {/* Resolution Selection */}
            {file && (
              <div className="mt-6">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Select Output Resolution:
                </label>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                  {resolutions.map((resolution) => (
                    <button
                      key={resolution.value}
                      onClick={() => setSelectedResolution(resolution.value)}
                      className={`p-3 rounded-lg border transition-colors ${
                        selectedResolution === resolution.value
                          ? 'border-yellow-500 bg-yellow-50 text-yellow-700'
                          : 'border-gray-300 hover:border-gray-400'
                      }`}
                    >
                      <div className="font-medium">{resolution.label}</div>
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Upload Button */}
            {file && (
              <div className="mt-6">
                <button
                  onClick={handleUpload}
                  disabled={uploading}
                  className="w-full bg-gradient-to-r from-yellow-500 via-orange-500 to-red-500 hover:from-yellow-600 hover:via-orange-600 hover:to-red-600 text-white font-semibold py-3 px-6 rounded-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {uploading ? 'Processing...' : '🌟 Enhance Video'}
                </button>
              </div>
            )}
          </div>

          {/* Progress Bar */}
          {uploading && (
            <div className="bg-white rounded-lg shadow-lg p-6 mb-6 border-2 border-yellow-200">
              <div className="mb-2 flex justify-between text-sm text-gray-600">
                <span>Processing video...</span>
                <span>{progress}%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div
                  className="bg-gradient-to-r from-yellow-500 to-orange-500 h-2 rounded-full transition-all duration-300"
                  style={{ width: `${progress}%` }}
                ></div>
              </div>
            </div>
          )}

          {/* Video Preview */}
          {videoPreview && (
            <div className="bg-white rounded-lg shadow-lg p-6 mb-6 border-2 border-yellow-200">
              <h3 className="text-lg font-semibold text-gray-800 mb-4">Video Preview</h3>
              <video
                controls
                className="w-full max-w-2xl mx-auto rounded-lg"
                src={videoPreview}
              >
                Your browser does not support the video tag.
              </video>
            </div>
          )}

          {/* Results */}
          {downloadUrl && (
            <div className="bg-white rounded-lg shadow-lg p-6 mb-6 border-2 border-green-200">
              <h3 className="text-lg font-semibold text-gray-800 mb-4">🌟 Enhanced Video Ready!</h3>
              <a
                href={downloadUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-block bg-gradient-to-r from-green-500 to-blue-500 hover:from-green-600 hover:to-blue-600 text-white font-semibold py-3 px-6 rounded-lg transition-colors"
              >
                Download Enhanced Video
              </a>
            </div>
          )}

          {/* Audio Analysis */}
          {audioAnalysis && (
            <div className="bg-white rounded-lg shadow-lg p-6 mb-6 border-2 border-blue-200">
              <h3 className="text-lg font-semibold text-gray-800 mb-4">Audio Analysis</h3>
              <div className="space-y-2">
                <p><strong>Has Audio:</strong> {audioAnalysis.has_audio ? 'Yes' : 'No'}</p>
                {audioAnalysis.audio_codec && (
                  <p><strong>Audio Codec:</strong> {audioAnalysis.audio_codec}</p>
                )}
                {!audioAnalysis.has_audio && (
                  <div className="mt-4">
                    <button
                      onClick={handleFixAudio}
                      disabled={uploading}
                      className="bg-orange-500 hover:bg-orange-600 text-white font-semibold py-2 px-4 rounded-lg transition-colors disabled:opacity-50"
                    >
                      Fix Audio (Add Silent Track)
                    </button>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Audio Fix Result */}
          {audioFixUrl && (
            <div className="bg-white rounded-lg shadow-lg p-6 mb-6 border-2 border-green-200">
              <h3 className="text-lg font-semibold text-gray-800 mb-4">Audio Fixed!</h3>
              <a
                href={audioFixUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-block bg-gradient-to-r from-green-500 to-blue-500 hover:from-green-600 hover:to-blue-600 text-white font-semibold py-3 px-6 rounded-lg transition-colors"
              >
                Download Audio-Fixed Video
              </a>
            </div>
          )}

          {/* Alert Messages */}
          {alert && (
            <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
              <p className="text-yellow-800">{alert}</p>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="text-center mt-12 text-gray-500">
          <p>🌟 Gold Star Evolution Enhancer • Powered by AI • Professional Quality • Free to Use</p>
          <p className="text-sm mt-2">Transform your videos with the power of artificial intelligence</p>
        </div>
      </div>
    </div>
  );
} 