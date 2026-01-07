import React, { useState } from "react";

interface ControlledFormProps {
  onSubmit: (formData: {
    name: string;
    description: string;
    image: File | null;
    price: string;
  }) => void;
  isSubmitting: boolean;
}

const ControlledForm: React.FC<ControlledFormProps> = ({ onSubmit, isSubmitting }) => {
  const [formData, setFormData] = useState({
    name: "",
    description: "",
    price: "",
    image: null as File | null,
    preview: null as string | null,
  });

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { id, value } = e.target;
    setFormData((prev) => ({ ...prev, [id]: value }));
  };

  const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setFormData((prev) => ({
        ...prev,
        image: file,
        preview: URL.createObjectURL(file),
      }));
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* Name Input */}
      <div>
        <label htmlFor="name" className="block text-sm font-medium text-gray-700">
          Name
        </label>
        <input
          type="text"
          id="name"
          value={formData.name}
          onChange={handleInputChange}
          className="p-4 rounded-full mt-1 block w-full border-gray-300 shadow-sm focus:border-cyan-500 focus:ring-cyan-500 sm:text-sm"
          placeholder="Enter NFT name"
        />
      </div>

      {/* Description Input */}
      <div>
        <label htmlFor="description" className="block text-sm font-medium text-gray-700">
          Description
        </label>
        <textarea
          id="description"
          value={formData.description}
          onChange={handleInputChange}
          className="mt-1 block w-full p-4 rounded-2xl border-gray-300 shadow-sm focus:border-cyan-500 focus:ring-cyan-500 sm:text-sm"
          placeholder="Enter NFT description"
          rows={4}
        ></textarea>
      </div>

      {/* Price Input */}
      <div>
        <label htmlFor="price" className="block text-sm font-medium text-gray-700">
          Price (in USDcx)
        </label>
        <input
          type="text"
          id="price"
          value={formData.price}
          onChange={handleInputChange}
          className="p-4 rounded-full mt-1 block w-full border-gray-300 shadow-sm focus:border-cyan-500 focus:ring-cyan-500 sm:text-sm"
          placeholder="Enter price in USDcx"
        />
      </div>

      {/* Image Upload */}
      <div>
        <label htmlFor="image" className="block text-sm font-medium text-gray-700">
          Upload Image
        </label>
        <input
          type="file"
          id="image"
          accept="image/*"
          onChange={handleImageUpload}
          className="mt-1 block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-cyan-50 file:text-cyan-600 hover:file:bg-cyan-100"
        />
        {formData.preview && (
          <div className="mt-4">
            <p className="text-sm text-gray-500">Image Preview:</p>
            <img
              src={formData.preview}
              alt="Preview"
              className="mt-2 w-full h-64 object-cover rounded-lg shadow-md"
            />
          </div>
        )}
      </div>

      {/* Submit Button */}
      <button
        type="submit"
        className="hover:cursor-pointer w-full bg-gradient-to-r from-cyan-500 to-blue-500 text-white py-2 px-4 rounded-md shadow-md hover:from-cyan-600 hover:to-blue-600 transition"
        disabled={isSubmitting}
      >
        {isSubmitting ? "Minting..." : "Mint NFT"}
      </button>
    </form>
  );
};

export default ControlledForm;