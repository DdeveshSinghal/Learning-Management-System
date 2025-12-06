# User Profile Component - Implementation Examples

## Basic Implementation

### Example 1: Simple Usage in App Component
```jsx
import { UserProfile } from './components/user-profile';

export default function App() {
  return (
    <div className="container mx-auto py-8">
      <UserProfile 
        userRole="student"
        userId={1}
        userName="John Doe"
      />
    </div>
  );
}
```

### Example 2: With Authentication Context
```jsx
import { useAuth } from './contexts/AuthContext';
import { UserProfile } from './components/user-profile';

export function ProfilePage() {
  const { user, isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return <div>Please log in first</div>;
  }

  return (
    <UserProfile 
      userRole={user.role}
      userId={user.id}
      userName={`${user.first_name} ${user.last_name}`}
    />
  );
}
```

### Example 3: With Routing
```jsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { UserProfile } from './components/user-profile';
import { useAuth } from './contexts/AuthContext';

function ProfileRoute() {
  const { user } = useAuth();
  
  return (
    <UserProfile 
      userRole={user?.role || 'student'}
      userId={user?.id || 0}
      userName={user?.name || 'User'}
    />
  );
}

export function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/profile" element={<ProfileRoute />} />
      </Routes>
    </BrowserRouter>
  );
}
```

## Advanced Patterns

### Example 4: With Custom Styling
```jsx
import { UserProfile } from './components/user-profile';
import './ProfilePage.css';

export function ProfilePage() {
  return (
    <div className="profile-container custom-theme">
      <UserProfile 
        userRole="teacher"
        userId={42}
        userName="Jane Smith"
      />
    </div>
  );
}
```

### Example 5: With Error Boundary
```jsx
import { ErrorBoundary } from 'react-error-boundary';
import { UserProfile } from './components/user-profile';

function ErrorFallback({error, resetErrorBoundary}) {
  return (
    <div role="alert">
      <p>Something went wrong loading the profile:</p>
      <pre>{error.message}</pre>
      <button onClick={resetErrorBoundary}>Try again</button>
    </div>
  )
}

export function ProfilePage({ userId, userName, userRole }) {
  return (
    <ErrorBoundary FallbackComponent={ErrorFallback}>
      <UserProfile 
        userId={userId}
        userName={userName}
        userRole={userRole}
      />
    </ErrorBoundary>
  );
}
```

### Example 6: With Redux/Store
```jsx
import { useSelector } from 'react-redux';
import { UserProfile } from './components/user-profile';

export function ProfilePage() {
  const user = useSelector(state => state.auth.user);
  
  if (!user) {
    return <div>Loading...</div>;
  }

  return (
    <UserProfile 
      userRole={user.role}
      userId={user.id}
      userName={user.full_name}
    />
  );
}
```

## API Integration Examples

### Example 7: Fetching Data Before Rendering
```jsx
import { useEffect, useState } from 'react';
import { UserProfile } from './components/user-profile';
import * as api from './services/api';

export function ProfilePageWithPrefetch() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const userData = await api.me();
        setUser(userData);
      } catch (error) {
        console.error('Failed to fetch user:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, []);

  if (loading) {
    return <div>Loading user data...</div>;
  }

  if (!user) {
    return <div>No user data found</div>;
  }

  return (
    <UserProfile 
      userRole={user.role}
      userId={user.id}
      userName={`${user.first_name} ${user.last_name}`}
    />
  );
}
```

### Example 8: With Data Refresh
```jsx
import { useState, useCallback } from 'react';
import { UserProfile } from './components/user-profile';

export function RefreshableProfilePage({ userId, userName, userRole }) {
  const [refreshKey, setRefreshKey] = useState(0);

  const handleRefresh = useCallback(() => {
    setRefreshKey(prev => prev + 1);
  }, []);

  return (
    <div>
      <button 
        onClick={handleRefresh}
        className="mb-4 px-4 py-2 bg-blue-500 text-white rounded"
      >
        Refresh Profile
      </button>
      
      <UserProfile 
        key={refreshKey}
        userRole={userRole}
        userId={userId}
        userName={userName}
      />
    </div>
  );
}
```

## Different User Roles

### Example 9: Student Profile
```jsx
<UserProfile 
  userRole="student"
  userId={101}
  userName="Alice Johnson"
/>
```

**Displays:**
- Student-specific fields (Grade, Roll Number, Parent Contact, etc.)
- Student statistics (GPA, Courses Enrolled, Attendance)
- Academic progress and achievements

### Example 10: Teacher Profile
```jsx
<UserProfile 
  userRole="teacher"
  userId={202}
  userName="Mr. Robert Wilson"
/>
```

**Displays:**
- Teacher-specific fields (Department, Qualification, Office Hours)
- Teaching statistics (Courses, Student Count, Rating)
- Course performance list

### Example 11: Admin Profile
```jsx
<UserProfile 
  userRole="admin"
  userId={999}
  userName="Admin User"
/>
```

**Displays:**
- Admin-specific fields (Position, Department, Access Level)
- System statistics (Users, Courses, Uptime)
- System health status

## Integration with Navigation

### Example 12: In Navigation/Dashboard
```jsx
import { Link } from 'react-router-dom';
import { useAuth } from './contexts/AuthContext';

export function Dashboard() {
  const { user } = useAuth();

  return (
    <div className="dashboard">
      <nav>
        <Link to="/">Home</Link>
        <Link to="/profile">My Profile</Link>
        <Link to="/settings">Settings</Link>
      </nav>

      <main>
        {/* Dashboard content */}
      </main>
    </div>
  );
}

export function ProfileLink() {
  const { user } = useAuth();

  if (!user) return null;

  return (
    <a href={`/profile/${user.id}`}>
      View Profile: {user.name}
    </a>
  );
}
```

### Example 13: With Modal Dialog
```jsx
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from './ui/dialog';
import { UserProfile } from './components/user-profile';

export function ProfileDialog({ isOpen, onClose, userId, userName, userRole }) {
  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-4xl max-h-screen overflow-y-auto">
        <DialogHeader>
          <DialogTitle>User Profile</DialogTitle>
        </DialogHeader>
        <UserProfile 
          userRole={userRole}
          userId={userId}
          userName={userName}
        />
      </DialogContent>
    </Dialog>
  );
}
```

## Data Flow Examples

### Example 14: Complete Data Flow
```jsx
/**
 * Data Flow:
 * 1. Props passed: userId, userRole, userName
 * 2. Component mounts → useEffect triggers
 * 3. fetchUserProfile() called → API requests
 * 4. Base user data fetched from /auth/me
 * 5. Role-specific profile fetched from /student-profiles/, /teacher-profiles/, or /admin-profiles/
 * 6. Data merged and setUserData, setFormData called
 * 7. UI renders with fetched data
 * 8. User can edit fields → handleInputChange updates formData
 * 9. User clicks Save → handleSave() called
 * 10. Only changed fields sent to API
 * 11. API responses processed
 * 12. UI updated with new data
 * 13. Success/error toast shown
 */

import { UserProfile } from './components/user-profile';

export function UserProfilePage() {
  // In a real app, these would come from routing or auth context
  const userId = 123;
  const userName = "John Doe";
  const userRole = "student";

  return <UserProfile {...{ userId, userName, userRole }} />;
}
```

## Testing Examples

### Example 15: Unit Test
```javascript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { UserProfile } from './user-profile';
import * as api from '../services/api';

jest.mock('../services/api');

describe('UserProfile Component', () => {
  const defaultProps = {
    userId: 1,
    userName: 'Test User',
    userRole: 'student'
  };

  beforeEach(() => {
    api.request.mockClear();
  });

  test('renders loading state initially', () => {
    api.request.mockImplementation(() => new Promise(() => {})); // Never resolves
    render(<UserProfile {...defaultProps} />);
    
    expect(screen.getByText(/Loading profile/i)).toBeInTheDocument();
  });

  test('loads student profile data', async () => {
    api.request.mockResolvedValueOnce({
      id: 1,
      first_name: 'John',
      last_name: 'Doe',
      phone: '1234567890'
    });

    render(<UserProfile {...defaultProps} />);

    await waitFor(() => {
      expect(screen.getByDisplayValue('1234567890')).toBeInTheDocument();
    });
  });

  test('saves edited profile', async () => {
    api.request.mockResolvedValueOnce({ id: 1, phone: '1234567890' });

    render(<UserProfile {...defaultProps} />);

    const editButton = await screen.findByText('Edit');
    fireEvent.click(editButton);

    const saveButton = screen.getByText('Save');
    fireEvent.click(saveButton);

    await waitFor(() => {
      expect(api.request).toHaveBeenCalledWith(
        expect.stringContaining('auth/me'),
        expect.any(Object)
      );
    });
  });
});
```

## Common Integration Scenarios

### Scenario 1: Multi-user Admin Panel
```jsx
export function UserManagementPanel() {
  const [selectedUserId, setSelectedUserId] = useState(null);
  const users = [
    { id: 1, name: 'Alice', role: 'student' },
    { id: 2, name: 'Bob', role: 'teacher' },
    { id: 3, name: 'Charlie', role: 'admin' }
  ];

  return (
    <div className="grid grid-cols-4 gap-4">
      <div>
        {users.map(user => (
          <button 
            key={user.id}
            onClick={() => setSelectedUserId(user.id)}
          >
            {user.name}
          </button>
        ))}
      </div>
      <div className="col-span-3">
        {selectedUserId && (
          <UserProfile 
            userId={selectedUserId}
            userName={users.find(u => u.id === selectedUserId)?.name}
            userRole={users.find(u => u.id === selectedUserId)?.role}
          />
        )}
      </div>
    </div>
  );
}
```

### Scenario 2: Profile in Settings Page
```jsx
export function SettingsPage() {
  const { user } = useAuth();

  return (
    <div className="settings">
      <h1>Settings</h1>
      <Tabs>
        <Tab name="Profile">
          <UserProfile 
            userId={user.id}
            userName={user.name}
            userRole={user.role}
          />
        </Tab>
        <Tab name="Notifications">
          {/* Notification settings */}
        </Tab>
        <Tab name="Privacy">
          {/* Privacy settings */}
        </Tab>
      </Tabs>
    </div>
  );
}
```

## Best Practices

✅ **Always provide all three required props**
✅ **Use authentication context for user data when possible**
✅ **Handle loading and error states**
✅ **Use error boundaries to catch component errors**
✅ **Test with different user roles**
✅ **Monitor API calls in development**
✅ **Validate data before saving**
✅ **Show appropriate notifications to users**
✅ **Keep component props stable (don't recreate objects)**
✅ **Use React DevTools to inspect component state**
