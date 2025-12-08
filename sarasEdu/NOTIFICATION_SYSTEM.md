# Notification System Documentation

## Overview
The notification system has been updated to fetch real notifications from the backend API instead of using static sample data.

## API Endpoints

The following endpoints have been added to `src/services/api.js`:

### 1. `getNotifications(filters = {})`
Fetches all notifications for the current user.

**Parameters:**
- `filters` (object) - Optional filters:
  - `limit` (number) - Limit the number of notifications (default: 50)
  - `offset` (number) - Pagination offset
  - `read` (boolean) - Filter by read status (true/false)

**Returns:** Array of notification objects with the following structure:
```javascript
{
  id: number,
  title: string,
  message: string,
  notification_type: 'success' | 'alert' | 'info',
  created_at: ISO 8601 timestamp,
  is_read: boolean
}
```

### 2. `markNotificationAsRead(id)`
Marks a single notification as read.

**Parameters:**
- `id` (number) - Notification ID

**Returns:** Updated notification object

### 3. `markAllNotificationsAsRead()`
Marks all notifications as read for the current user.

**Returns:** Confirmation message

### 4. `deleteNotification(id)`
Deletes a single notification.

**Parameters:**
- `id` (number) - Notification ID

**Returns:** Success response

### 5. `deleteAllNotifications()`
Deletes all notifications for the current user.

**Returns:** Success response

## Frontend Implementation

### NotificationCenter Component
Located in `src/components/notification-center.jsx`

**Features:**
- Displays a bell icon in the header with unread count badge
- Opens a dialog when clicked showing all notifications
- Auto-fetches notifications when dialog opens
- Supports marking notifications as read (individual and bulk)
- Supports deleting notifications (individual and bulk)
- Error handling with retry functionality
- Loading states for better UX

**Key Functions:**
- `fetchNotifications()` - Fetches notifications from API
- `handleMarkAsRead(id)` - Marks single notification as read
- `handleMarkAllAsRead()` - Marks all notifications as read
- `handleDeleteNotification(id)` - Deletes single notification
- `handleClearAll()` - Deletes all notifications

### Notification Mapping
API responses are mapped to the following internal format:
```javascript
{
  id: number,
  type: 'success' | 'alert' | 'info',
  title: string,
  message: string,
  timestamp: Date object,
  read: boolean,
  notification_id: number  // Backend ID
}
```

## Backend Requirements

Your backend API should implement the following endpoints:

### GET `/api/notifications/`
Query Parameters:
- `limit` (optional) - Number of notifications to return
- `offset` (optional) - Pagination offset
- `read` (optional) - Filter by read status (true/false)

Response:
```json
{
  "results": [
    {
      "id": 1,
      "title": "Assignment Submitted",
      "message": "Your assignment has been submitted",
      "notification_type": "success",
      "created_at": "2025-12-08T10:30:00Z",
      "is_read": false
    }
  ]
}
```

### POST `/api/notifications/{id}/mark-as-read/`
Marks notification as read.

### POST `/api/notifications/mark-all-as-read/`
Marks all notifications as read.

### DELETE `/api/notifications/{id}/`
Deletes a notification.

### DELETE `/api/notifications/delete-all/`
Deletes all notifications.

## Usage in Components

To use the notification center in your app:

```javascript
import { NotificationCenter } from './components/notification-center';

// In your header/layout component:
<NotificationCenter />
```

The component is already integrated into `optimized-lms-dashboard.jsx` in the header.

## Error Handling

- Failed API calls show a toast error message
- Users can retry by clicking the "Try Again" button
- Optimistic UI updates are reverted on error
- Network errors are caught and logged to console

## Notification Types

The system supports three types of notifications:
- `success` (Green icon) - Positive actions (assignment submitted, etc.)
- `alert` (Red icon) - Important alerts (deadline approaching, etc.)
- `info` (Blue icon) - General information (announcements, etc.)

## Time Formatting

Timestamps are formatted as:
- Less than 1 minute: "Just now"
- Less than 1 hour: "5m ago", "30m ago"
- Less than 24 hours: "2h ago", "12h ago"
- Less than 7 days: "2d ago", "5d ago"
- Older: Full date (e.g., "12/8/2025")

## Future Enhancements

Potential improvements:
1. Real-time notifications using WebSocket
2. Notification categories/filtering
3. Notification preferences per user
4. Sound/browser notifications
5. Notification grouping
6. Archive functionality
