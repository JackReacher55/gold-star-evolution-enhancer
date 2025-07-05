import { useRouter } from 'next/router';

export default function Result() {
  const router = useRouter();
  const { jobId } = router.query;
  const downloadUrl = jobId ? `http://localhost:8000/download/${jobId}` : '';
  return (
    <div style={{ maxWidth: 600, margin: 'auto', padding: 20 }}>
      <h1>Download Enhanced Video</h1>
      {jobId ? (
        <a href={downloadUrl}>Download</a>
      ) : (
        <p>No job ID found.</p>
      )}
    </div>
  );
} 