import axios from 'axios';


// Function to get Pinata API key (if using API key auth)
const getPinataAPIKey = () => {
  return process.env.REACT_APP_PINATA_API_KEY;
};

const getPinataJWT = () => {
  return process.env.REACT_APP_PINATA_JWT;
};

export const uploadToPinata = async (file, metadata = {}) => {
  try {
    if (!file) throw new Error('No file provided');
    if (file.size > 100 * 1024 * 1024) {
      throw new Error('File size exceeds 100MB limit');
    }

    const formData = new FormData();
    formData.append('file', file, file.name);
    formData.append('network', 'public');
    formData.append('name', file.name);
    
    // Add metadata with credential information
    formData.append(
      'keyvalues',
      JSON.stringify({
        type: 'academic-credential',
        timestamp: Date.now().toString(),
        ...metadata
      })
    );

    const token = getPinataJWT();
    if (!token) throw new Error('Missing Pinata authentication token');

    const headers = {
      'Content-Type': 'multipart/form-data',
      Authorization: `Bearer ${token}`,
    };

    const response = await axios.post(
      'https://uploads.pinata.cloud/v3/files',
      formData,
      {
        maxContentLength: 100 * 1024 * 1024,
        maxBodyLength: 100 * 1024 * 1024,
        headers,
      }
    );

    // Return the CID for the file
      return {
      cid: response.data.data.cid,
      url: `https://gateway.pinata.cloud/ipfs/${response.data.cid}`
    }

  } catch (error) {
    let errorMessage = 'Failed to upload document to Pinata';
    
    if (error.response) {
      const { status, data } = error.response;
      errorMessage += ` (Status ${status})`;
      
      if (data && data.error) {
        errorMessage += `: ${data.error}`;
      } else if (data && data.message) {
        errorMessage += `: ${data.message}`;
      }
    } else if (error.request) {
      errorMessage += ': No response received';
    } else {
      errorMessage += `: ${error.message}`;
    }
    
    console.error('Pinata upload error:', error);
    throw new Error(errorMessage);
  }
  
};


export const fetchFromPinata = async (fileId) => {
  try {
    if (!fileId) throw new Error('No file ID provided');

    const token = getPinataJWT() || getPinataAPIKey();
    if (!token) throw new Error('Missing Pinata authentication token');

    const response = await axios.get(
      `https://api.pinata.cloud/v3/files/${fileId}`,
      {
        headers: { Authorization: `Bearer ${token}` },
        responseType: 'blob',
        timeout: 30000,
      }
    );

    if (!response.data) {
      throw new Error('No data received from Pinata');
    }

    const mimeType = response.headers['content-type'] || 'application/octet-stream';
    const blob = new Blob([response.data], { type: mimeType });
    return URL.createObjectURL(blob);
  } catch (error) {
    let errorMessage = 'Failed to retrieve document from Pinata';
    if (error.response?.status === 404) {
      errorMessage = 'Document not found';
    }
    console.error('Pinata fetch error:', error);
    throw new Error(errorMessage);
  }
};

export const getFileDownloadLink = (fileId) => {
  if (!fileId) return '';
  // Use public Pinata gateway
  return `https://indigo-high-mandrill-170.mypinata.cloud/ipfs/${fileId}`;
};
// New function to get file metadata
export const getFileMetadata = async (fileId) => {
  try {
    if (!fileId) throw new Error('No file ID provided');

    const token = getPinataJWT() || getPinataAPIKey();
    if (!token) throw new Error('Missing Pinata authentication token');

    const response = await axios.get(
      `https://api.pinata.cloud/v3/files/${fileId}/metadata`,
      {
        headers: { Authorization: `Bearer ${token}` },
      }
    );

    return response.data;
  } catch (error) {
    console.error('Failed to fetch file metadata:', error);
    throw new Error('Failed to retrieve file information');
  }
};
