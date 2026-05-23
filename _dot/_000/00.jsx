import React, { useState } from 'react';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';

const DatePickerComponent = ({
  initialDate = null,
  label = "Select a Date",
  onDateChange = () => {}
}) => {
  const [selectedDate, setSelectedDate] = useState(initialDate);

  const handleDateChange = (date) => {
    setSelectedDate(date);
    onDateChange(date); // Notify parent component
    sendDateToServer(date);
  };

  const sendDateToServer = async (date) => {
    if (!date) return;
    const formattedDate = date.toISOString().split('T')[0];

    try {
      const response = await fetch('http://example.com', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ date: formattedDate }),
      });
      if (response.ok) console.log('Date sent:', formattedDate);
    } catch (error) {
      console.error('Error:', error);
    }
  };

  return (
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h2>{label}</h2>
      <DatePicker
        selected={selectedDate}
        onChange={handleDateChange}
        dateFormat="yyyy/MM/dd"
        placeholderText="Select a date"
      />
      {selectedDate && (
        <p style={{ marginTop: '10px' }}>
          Selected date: {selectedDate.toLocaleDateString()}
        </p>
      )}
    </div>
  );
};

export default DatePickerComponent;
