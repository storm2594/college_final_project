import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { Target, CheckCircle, Clock, Trash2, Plus, ArrowRight, Loader } from 'lucide-react';

const API_BASE_URL = '/api';

function App() {
  const [tasks, setTasks] = useState([]);
  const [stats, setStats] = useState([]);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  const fetchTasks = async () => {
    try {
      const res = await axios.get(`${API_BASE_URL}/tasks`);
      setTasks(res.data);
    } catch (err) {
      console.error('Error fetching tasks', err);
    } finally {
      setLoading(false);
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
    setSubmitting(true);
    try {
      await axios.post(`${API_BASE_URL}/tasks`, { title, description });
      setTitle('');
      setDescription('');
      await fetchTasks();
      await fetchStats();
    } catch (err) {
      console.error('Error adding task', err);
    } finally {
      setSubmitting(false);
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

  const completedCount = tasks.filter(t => t.status === 'completed').length;
  const pendingCount = tasks.filter(t => t.status === 'pending').length;
  const progressPercent = tasks.length === 0 ? 0 : Math.round((completedCount / tasks.length) * 100);

  return (
    <div className="min-h-screen bg-[#0B0F19] text-gray-100 font-sans selection:bg-indigo-500/30">
      {/* Dynamic Background Gradients */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none z-0">
        <div className="absolute -top-[20%] -left-[10%] w-[50%] h-[50%] rounded-full bg-indigo-600/20 blur-[120px] mix-blend-screen animate-pulse" style={{ animationDuration: '8s' }}></div>
        <div className="absolute top-[40%] -right-[10%] w-[40%] h-[60%] rounded-full bg-fuchsia-600/10 blur-[120px] mix-blend-screen animate-pulse" style={{ animationDuration: '12s' }}></div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-12 relative z-10 space-y-12">
        
        {/* Header Section */}
        <header className="flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
          <div className="space-y-2">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-indigo-500/10 border border-indigo-500/20 text-indigo-400 text-sm font-semibold mb-4">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-indigo-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-indigo-500"></span>
              </span>
              System Online
            </div>
            <h1 className="text-4xl md:text-5xl font-black tracking-tight text-white flex items-center gap-4">
              <div className="p-3 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-2xl shadow-lg shadow-indigo-500/20">
                <Target className="w-8 h-8 text-white" strokeWidth={2.5} />
              </div>
              FlowState
            </h1>
            <p className="text-gray-400 text-lg max-w-xl leading-relaxed">Engineered for extreme performance. Build and orchestrate your tasks seamlessly through the cloud.</p>
          </div>
          
          {/* Quick Metrics */}
          <div className="flex gap-4">
            <div className="px-6 py-4 rounded-2xl bg-white/5 border border-white/10 backdrop-blur-md">
              <div className="text-gray-400 text-sm font-medium mb-1">Completion Rate</div>
              <div className="text-3xl font-bold flex items-baseline gap-1 text-white">
                {progressPercent}<span className="text-lg text-indigo-400">%</span>
              </div>
            </div>
          </div>
        </header>

        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
          
          {/* Left Column (Create Task & Analytics) */}
          <div className="lg:col-span-5 space-y-8">
            
            {/* Create Task Card */}
            <div className="bg-white/[0.03] backdrop-blur-xl p-8 rounded-3xl border border-white/10 shadow-2xl relative overflow-hidden group">
              <div className="absolute inset-0 bg-gradient-to-br from-indigo-500/5 to-purple-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
              
              <h2 className="text-2xl font-bold text-white mb-6 flex items-center gap-2">
                <Plus className="w-6 h-6 text-indigo-400" /> Integrate Task
              </h2>
              
              <form onSubmit={addTask} className="space-y-5 relative">
                <div className="space-y-1.5">
                  <label className="block text-sm font-medium text-gray-400 ml-1">Task Nomenclature</label>
                  <input
                    type="text"
                    placeholder="e.g. Optimize React rendering cycle"
                    className="w-full bg-black/40 text-white rounded-xl border border-white/10 px-4 py-3 placeholder:text-gray-600 focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition-all duration-300"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    required
                  />
                </div>
                
                <div className="space-y-1.5">
                  <label className="block text-sm font-medium text-gray-400 ml-1">Execution Details</label>
                  <textarea
                    placeholder="Provide execution context..."
                    className="w-full bg-black/40 text-white rounded-xl border border-white/10 px-4 py-3 placeholder:text-gray-600 focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition-all duration-300 resize-none"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    rows="3"
                  />
                </div>

                <div className="pt-2">
                  <button
                    type="submit"
                    disabled={submitting}
                    className="w-full flex items-center justify-center gap-2 py-3.5 px-6 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white font-semibold tracking-wide shadow-lg shadow-indigo-600/30 hover:shadow-indigo-500/50 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed group active:scale-[0.98]"
                  >
                    {submitting ? <Loader className="w-5 h-5 animate-spin" /> : 'Deploy to Cloud'}
                    {!submitting && <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />}
                  </button>
                </div>
              </form>
            </div>

            {/* Analytics Card */}
            <div className="bg-white/[0.03] backdrop-blur-xl p-8 rounded-3xl border border-white/10 shadow-2xl">
              <h2 className="text-xl font-bold text-white mb-4">Cluster Activity</h2>
              <div className="h-48 w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={stats}>
                    <defs>
                      <linearGradient id="colorCount" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#6366f1" stopOpacity={0.8}/>
                        <stop offset="95%" stopColor="#6366f1" stopOpacity={0}/>
                      </linearGradient>
                    </defs>
                    <XAxis dataKey="status" stroke="#6b7280" tick={{fill: '#9ca3af', fontSize: 12}} axisLine={false} tickLine={false} />
                    <Tooltip 
                      contentStyle={{ backgroundColor: '#111827', borderColor: '#374151', borderRadius: '12px', color: '#fff' }}
                      itemStyle={{ color: '#fff' }}
                    />
                    <Area type="monotone" dataKey="count" stroke="#818cf8" strokeWidth={3} fillOpacity={1} fill="url(#colorCount)" />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>

          </div>

          {/* Right Column (Task List) */}
          <div className="lg:col-span-7 bg-white/[0.02] backdrop-blur-xl rounded-3xl border border-white/10 shadow-2xl min-h-[600px] flex flex-col overflow-hidden">
            <div className="p-8 border-b border-white/5 flex items-center justify-between">
              <h2 className="text-2xl font-bold text-white flex items-center gap-3">
                <Clock className="w-6 h-6 text-fuchsia-400" /> Execution Queue
              </h2>
              <div className="flex gap-3 text-sm font-medium">
                <span className="flex items-center gap-1.5 text-gray-400 bg-white/5 px-3 py-1 rounded-lg border border-white/5">
                  <span className="w-2 h-2 rounded-full bg-amber-400"></span>
                  {pendingCount} Pending
                </span>
                <span className="flex items-center gap-1.5 text-gray-400 bg-white/5 px-3 py-1 rounded-lg border border-white/5">
                  <span className="w-2 h-2 rounded-full bg-emerald-400"></span>
                  {completedCount} Resolved
                </span>
              </div>
            </div>

            <div className="p-4 flex-1 overflow-y-auto custom-scrollbar">
              {loading ? (
                <div className="flex flex-col items-center justify-center h-full space-y-4 opacity-50">
                  <Loader className="w-8 h-8 animate-spin text-indigo-400" />
                  <p className="text-gray-400">Syncing nodes...</p>
                </div>
              ) : tasks.length === 0 ? (
                <div className="flex flex-col items-center justify-center h-full text-center p-8 opacity-50">
                  <Target className="w-16 h-16 text-gray-600 mb-4" />
                  <h3 className="text-xl font-bold text-white mb-2">No active tasks</h3>
                  <p className="text-gray-400 max-w-sm">The execution queue is strictly empty. Deploy a new task to initiate tracking.</p>
                </div>
              ) : (
                <ul className="space-y-3">
                  {tasks.map((task) => (
                    <li 
                      key={task.id} 
                      className="group flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-5 rounded-2xl bg-white/5 border border-white/5 hover:border-indigo-500/30 hover:bg-white/10 transition-all duration-300"
                    >
                      <div className="flex-1 space-y-1">
                        <h3 className={`text-lg font-bold transition-colors ${task.status === 'completed' ? 'text-gray-500 line-through decoration-gray-600' : 'text-gray-100'}`}>
                          {task.title}
                        </h3>
                        {task.description && (
                          <p className="text-gray-400 text-sm line-clamp-2 leading-relaxed">
                            {task.description}
                          </p>
                        )}
                      </div>
                      
                      <div className="flex items-center gap-2 shrink-0">
                        <button
                          onClick={() => updateStatus(task.id, task.status)}
                          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-semibold transition-all duration-300 ${
                            task.status === 'completed' 
                            ? 'bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20 border border-emerald-500/20' 
                            : 'bg-amber-500/10 text-amber-400 hover:bg-amber-500/20 border border-amber-500/20'
                          }`}
                        >
                          {task.status === 'completed' ? <CheckCircle className="w-4 h-4" /> : <Clock className="w-4 h-4" />}
                          {task.status.toUpperCase()}
                        </button>
                        <button
                          onClick={() => deleteTask(task.id)}
                          className="p-2.5 rounded-xl text-red-400 hover:text-red-300 hover:bg-red-500/10 border border-transparent hover:border-red-500/20 transition-all duration-300"
                          title="Delete Task"
                        >
                          <Trash2 className="w-5 h-5" />
                        </button>
                      </div>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
