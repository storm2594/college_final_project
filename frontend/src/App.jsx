import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar } from 'recharts';
import { Activity, CheckCircle, Clock } from 'lucide-react';

const API_BASE_URL = '/api'; // Will be proxied in dev, or routed via ALB in prod

function App() {
  const [tasks, setTasks] = useState([]);
  const [stats, setStats] = useState([]);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');

  const fetchTasks = async () => {
    try {
      const res = await axios.get(`${API_BASE_URL}/tasks`);
      setTasks(res.data);
    } catch (err) {
      console.error('Error fetching tasks', err);
    }
  };

  const fetchStats = async () => {
    try {
      const res = await axios.get(`${API_BASE_URL}/stats`);
      setStats(res.data);
    } catch (err) {
      console.error('Error fetching stats', err);
    }
  };

  useEffect(() => {
    fetchTasks();
    fetchStats();
  }, []);

  const addTask = async (e) => {
    e.preventDefault();
    if (!title) return;
    try {
      await axios.post(`${API_BASE_URL}/tasks`, { title, description });
      setTitle('');
      setDescription('');
      fetchTasks();
      fetchStats();
    } catch (err) {
      console.error('Error adding task', err);
    }
  };

  const updateStatus = async (id, currentStatus) => {
    const newStatus = currentStatus === 'pending' ? 'completed' : 'pending';
    try {
      await axios.put(`${API_BASE_URL}/tasks/${id}`, { status: newStatus });
      fetchTasks();
      fetchStats();
    } catch (err) {
      console.error('Error updating task', err);
    }
  };

  const deleteTask = async (id) => {
    try {
      await axios.delete(`${API_BASE_URL}/tasks/${id}`);
      fetchTasks();
      fetchStats();
    } catch (err) {
      console.error('Error deleting task', err);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 text-gray-900 p-8 font-sans">
      <div className="max-w-6xl mx-auto space-y-8">
        <header className="flex items-center justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-extrabold text-indigo-700 items-center flex gap-3">
              <Activity className="w-8 h-8 text-indigo-600" />
              Cloud-Native Task Analytics Dashboard
            </h1>
            <p className="text-gray-500 mt-2">Manage your tasks and monitor statuses in real-time.</p>
          </div>
        </header>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Form and List */}
          <div className="col-span-2 space-y-8">
            <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
              <h2 className="text-xl font-bold mb-4 text-gray-800">Add New Task</h2>
              <form onSubmit={addTask} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Title</label>
                  <input
                    type="text"
                    className="mt-1 block w-full rounded-md border-gray-300 border p-2 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Description</label>
                  <textarea
                    className="mt-1 block w-full rounded-md border-gray-300 border p-2 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    rows="3"
                  />
                </div>
                <button
                  type="submit"
                  className="inline-flex justify-center rounded-md border border-transparent bg-indigo-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                >
                  Create Task
                </button>
              </form>
            </div>

            <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
              <h2 className="text-xl font-bold mb-4 text-gray-800">Recent Tasks</h2>
              <ul className="divide-y divide-gray-200">
                {tasks.map((task) => (
                  <li key={task.id} className="py-4 flex items-center justify-between">
                    <div className="flex flex-col">
                      <span className={`font-medium ${task.status === 'completed' ? 'text-gray-400 line-through' : 'text-gray-900'}`}>{task.title}</span>
                      <span className="text-sm text-gray-500">{task.description}</span>
                    </div>
                    <div className="flex gap-2">
                      <button
                        onClick={() => updateStatus(task.id, task.status)}
                        className={`p-2 rounded-full ${task.status === 'completed' ? 'text-green-600 bg-green-50' : 'text-gray-400 bg-gray-50 hover:bg-gray-100'}`}
                      >
                        {task.status === 'completed' ? <CheckCircle className="w-5 h-5" /> : <Clock className="w-5 h-5" />}
                      </button>
                      <button
                        onClick={() => deleteTask(task.id)}
                        className="p-2 rounded-full text-red-500 bg-red-50 hover:bg-red-100"
                      >
                        Delete
                      </button>
                    </div>
                  </li>
                ))}
                {tasks.length === 0 && <p className="text-gray-500 italic">No tasks yet.</p>}
              </ul>
            </div>
          </div>

          {/* Analytics Sidebar */}
          <div className="space-y-8">
            <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
              <h2 className="text-xl font-bold mb-4 text-gray-800">Status Analytics</h2>
              <div className="h-64">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={stats}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} />
                    <XAxis dataKey="status" />
                    <YAxis />
                    <Tooltip cursor={{fill: '#f3f4f6'}} />
                    <Bar dataKey="count" fill="#6366f1" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
