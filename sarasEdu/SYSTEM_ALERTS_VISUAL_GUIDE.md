# System Alerts - Visual Guide & Examples

## Dashboard Visual Preview

### Admin Dashboard - System Alerts Card

```
┌─────────────────────────────────────────────────────────────────────┐
│  🔴 System Alerts                                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ◼ Database Connection Timeout                                      │
│  Database response time exceeding threshold (2.5s average)          │
│  Service: core_user                                                 │
│                                             critical │ Active       │
│                                                                       │
│  ◼ API Response Time Degradation                                    │
│  Average response time increased to 2.5s (normal: 200ms)           │
│  Service: course_api                                                │
│                                               high │ Investigating │
│                                                                       │
│  ◼ Email Service Connection Failed                                  │
│  Unable to connect to SMTP server                                   │
│  Service: smtp_server                                               │
│                                             medium │ Monitoring    │
│                                                                       │
│  ◼ Storage Usage Warning                                            │
│  Disk usage at 75% capacity                                         │
│  Service: minio_storage                                             │
│                                                low │ Active        │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

## Color Scheme Reference

### Severity Colors

```
🔴 CRITICAL
   Dot Color: bg-red-600 (#DC2626)
   Background: bg-red-50 (#FEF2F2)
   Badge: destructive (Red)
   Usage: System down, major failure
   
🟠 HIGH  
   Dot Color: bg-orange-500 (#F97316)
   Background: bg-orange-50 (#FEF3C7)
   Badge: destructive (Red)
   Usage: Severe degradation, immediate action needed
   
🟡 MEDIUM
   Dot Color: bg-yellow-500 (#EAB308)
   Background: bg-yellow-50 (#FEFCE8)
   Badge: default (Gray)
   Usage: Noticeable impact, needs attention soon
   
🔵 LOW
   Dot Color: bg-blue-500 (#3B82F6)
   Background: bg-blue-50 (#EFF6FF)
   Badge: secondary (Gray)
   Usage: Informational, monitor
```

## Status Badge States

```
Status: "active"      → Badge: "Active"       → Red/Orange background
Status: "resolved"    → Badge: "Resolved"     → Green background
Status: "monitoring"  → Badge: "Monitoring"   → Yellow background
Status: "investigating" → Badge: "Investigating" → Orange background
```

## Component Structure

```jsx
<Card>
  <CardHeader>
    <CardTitle>
      <AlertTriangle /> System Alerts
    </CardTitle>
  </CardHeader>
  
  <CardContent>
    {systemAlerts.length === 0 ? (
      "All systems operational"
    ) : (
      <div>
        {systemAlerts.slice(0, 6).map(alert => (
          <div className={`severity-${alert.severity}-background`}>
            {/* Severity Dot */}
            <div className={`severity-${alert.severity}-dot`} />
            
            {/* Alert Info */}
            <div>
              <strong>{alert.title}</strong>
              <p>{alert.description}</p>
              <small>Service: {alert.affected_service}</small>
            </div>
            
            {/* Badges */}
            <Badge severity>{alert.severity}</Badge>
            <Badge status>{alert.status}</Badge>
          </div>
        ))}
      </div>
    )}
  </CardContent>
</Card>
```

## Example Alerts

### Example 1: Database Alert (Critical)

```
┌─ Critical Database Alert ────────────────────────────────────────┐
│                                                                   │
│ 🔴 Title: Database Connection Pool Exhausted                    │
│    Description: All connection slots are in use, new connections│
│                 being rejected                                   │
│    Service: primary_db                                           │
│    Affected Users: 120                                           │
│    Status: Active                                                │
│                                                                   │
│    Resolution Steps:                                             │
│    1. Increase connection pool size to 150                       │
│    2. Investigate slow queries (>3s execution time)              │
│    3. Add database indexes on frequently queried columns         │
│    4. Monitor connection usage for 24 hours                      │
│                                                                   │
│    Metadata:                                                      │
│    {                                                              │
│      "max_connections": 100,                                     │
│      "active_connections": 100,                                  │
│      "waiting_connections": 25,                                  │
│      "avg_query_time": "3.2s",                                   │
│      "threshold": "1.5s"                                         │
│    }                                                              │
│                                                                   │
│ Created: 2024-01-15 10:30:00 UTC                                 │
│ Duration: 45 minutes                                             │
│                                                                   │
│ [critical] [Active]                                              │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Example 2: API Alert (High)

```
┌─ High Priority API Alert ────────────────────────────────────────┐
│                                                                   │
│ 🟠 Title: API Response Time Degradation                         │
│    Description: Average response time increased to 2.5s         │
│                 (normal: 200ms) - 12.5x slower than baseline    │
│    Service: course_api                                           │
│    Affected Users: 250                                           │
│    Status: Investigating                                         │
│                                                                   │
│    Resolution Steps:                                             │
│    1. Scale up API servers (add 2 more instances)                │
│    2. Clear Redis cache to eliminate stale data                  │
│    3. Optimize N+1 database queries in CourseListView            │
│    4. Enable response compression for large payloads             │
│                                                                   │
│    Metadata:                                                      │
│    {                                                              │
│      "endpoints": [                                               │
│        "GET /api/courses/",                                      │
│        "GET /api/enrollments/"                                   │
│      ],                                                           │
│      "p50_response_time": "2.1s",                                │
│      "p95_response_time": "4.5s",                                │
│      "error_rate": "2.3%",                                       │
│      "cpu_usage": "87%",                                         │
│      "memory_usage": "92%"                                       │
│    }                                                              │
│                                                                   │
│ Created: 2024-01-15 11:15:00 UTC                                 │
│ Duration: 20 minutes (still active)                              │
│                                                                   │
│ [high] [Investigating]                                           │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Example 3: Email Service Alert (Medium)

```
┌─ Medium Priority Email Alert ────────────────────────────────────┐
│                                                                   │
│ 🟡 Title: Email Service Connection Timeout                      │
│    Description: SMTP server not responding to connection        │
│                 requests within timeout window (30s)             │
│    Service: email_smtp                                           │
│    Affected Users: 15                                            │
│    Status: Monitoring                                            │
│                                                                   │
│    Resolution Steps:                                             │
│    1. Check SMTP server logs for errors                          │
│    2. Verify firewall rules allow outbound port 587              │
│    3. Contact email provider support if issue persists           │
│    4. Implement email retry queue with exponential backoff       │
│                                                                   │
│    Metadata:                                                      │
│    {                                                              │
│      "smtp_server": "mail.example.com:587",                      │
│      "failed_attempts": 43,                                      │
│      "success_rate": "87.5%",                                    │
│      "avg_connection_time": "2.1s"                               │
│    }                                                              │
│                                                                   │
│ Created: 2024-01-15 12:00:00 UTC                                 │
│ Resolved: 2024-01-15 12:45:00 UTC                                │
│ Duration: 45 minutes (now resolved)                              │
│                                                                   │
│ [medium] [Monitoring]                                            │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Example 4: Storage Alert (Low)

```
┌─ Low Priority Storage Alert ──────────────────────────────────────┐
│                                                                   │
│ 🔵 Title: Disk Usage at High Capacity                           │
│    Description: Storage device usage exceeded 80% threshold,     │
│                 approaching critical limit of 90%                │
│    Service: minio_storage                                        │
│    Affected Users: 0 (informational)                             │
│    Status: Active                                                │
│                                                                   │
│    Resolution Steps:                                             │
│    1. Archive old assignment submissions (>6 months)             │
│    2. Clean up temporary upload files                            │
│    3. Move historical logs to external storage                   │
│    4. Order additional storage capacity from provider             │
│    5. Implement automatic cleanup policies                       │
│                                                                   │
│    Metadata:                                                      │
│    {                                                              │
│      "total_capacity": "1TB",                                    │
│      "used_space": "850GB",                                      │
│      "available_space": "150GB",                                  │
│      "usage_percentage": 85.0,                                   │
│      "growth_rate": "2GB/day",                                   │
│      "estimated_full_date": "2024-01-25"                         │
│    }                                                              │
│                                                                   │
│ Created: 2024-01-15 08:00:00 UTC                                 │
│ Duration: 4 hours (still active)                                 │
│                                                                   │
│ [low] [Active]                                                   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## JSON Response Examples

### Full Alert Response

```json
{
  "id": 1,
  "alert_type": "database",
  "severity": "critical",
  "status": "active",
  "title": "Database Connection Pool Exhausted",
  "description": "All connection slots are in use, new connections being rejected",
  "affected_service": "primary_db",
  "resolution_steps": "1. Increase connection pool size\n2. Investigate slow queries\n3. Add database indexes",
  "affected_users_count": 120,
  "metadata": {
    "max_connections": 100,
    "active_connections": 100,
    "queue_size": 45,
    "average_query_time": "3.2s",
    "slow_query": "SELECT * FROM enrollments WHERE user_id = ? AND course_id = ?"
  },
  "created_at": "2024-01-15T10:30:00.000000Z",
  "resolved_at": null
}
```

### Multiple Alerts Response

```json
{
  "count": 4,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "alert_type": "database",
      "severity": "critical",
      "status": "active",
      ...
    },
    {
      "id": 2,
      "alert_type": "api",
      "severity": "high",
      "status": "investigating",
      ...
    },
    {
      "id": 3,
      "alert_type": "email",
      "severity": "medium",
      "status": "monitoring",
      ...
    },
    {
      "id": 4,
      "alert_type": "storage",
      "severity": "low",
      "status": "active",
      ...
    }
  ]
}
```

### Empty Alerts Response

```json
{
  "count": 0,
  "next": null,
  "previous": null,
  "results": []
}
```

## Dashboard Layout

### Before (Using Announcements)

```
Admin Dashboard
├── Statistics Cards
│   ├── Total Users
│   ├── Active Courses
│   ├── System Health
│   └── Notifications
│
├── Recent Platform Activity
│   ├── User registrations (announcements)
│   ├── Course publications (announcements)
│   └── Generic updates (announcements)
│
├── System Alerts ❌ (Using announcement data)
│   ├── Announcement 1
│   ├── Announcement 2
│   └── Announcement 3
│
└── Administrative Actions
    ├── Manage Users
    ├── Course Overview
    ├── Send Notice
    └── System Settings
```

### After (Using Real System Alerts)

```
Admin Dashboard
├── Statistics Cards
│   ├── Total Users
│   ├── Active Courses
│   ├── System Health
│   └── Notifications
│
├── Recent Platform Activity ✅
│   ├── UserPlus    User registration (Activity logs)
│   ├── BookMarked  Course published (Activity logs)
│   ├── CheckCircle Assignment submitted (Activity logs)
│   └── Settings    System maintenance (Activity logs)
│
├── System Alerts ✅ (Real system health alerts)
│   ├── 🔴 Database issue (CRITICAL)
│   ├── 🟠 API degradation (HIGH)
│   ├── 🟡 Email timeout (MEDIUM)
│   └── 🔵 Disk space warning (LOW)
│
└── Administrative Actions
    ├── Manage Users
    ├── Course Overview
    ├── Send Notice
    └── System Settings
```

## Frontend Integration Code Example

```javascript
// State
const [systemAlerts, setSystemAlerts] = useState([]);

// Fetching
useEffect(() => {
  apiRequest('/system-alerts/')
    .then(data => setSystemAlerts(normalizeArray(data)))
    .catch(() => setSystemAlerts([]));
}, []);

// Rendering
{systemAlerts.length === 0 ? (
  <div className="text-sm text-muted-foreground">All systems operational</div>
) : (
  systemAlerts.slice(0, 6).map(alert => (
    <div key={alert.id} className={`p-3 border rounded-lg bg-${alert.severity}-50`}>
      <div className={`w-2 h-2 rounded-full bg-${alert.severity}-600`} />
      <div>
        <p className="font-medium">{alert.title}</p>
        <p className="text-xs text-muted-foreground">{alert.description}</p>
        {alert.affected_service && (
          <p className="text-xs text-muted-foreground">Service: {alert.affected_service}</p>
        )}
      </div>
      <div className="flex gap-2">
        <Badge variant={alert.severity === 'critical' || alert.severity === 'high' ? 'destructive' : 'default'}>
          {alert.severity}
        </Badge>
        <Badge variant="outline">{alert.status}</Badge>
      </div>
    </div>
  ))
)}
```

## Alert Type Icons (In Admin Alerts Context)

| Alert Type | Icon | Typical Usage |
|-----------|------|--------------|
| Backend | ⚙️ | API/application server issues |
| Database | 🗄️ | DB connection, performance |
| Server | 🖥️ | Infrastructure, resources |
| Payment | 💳 | Payment gateway failures |
| Storage | 📦 | File storage, disk space |
| API | 🔌 | API endpoint failures |
| Email | ✉️ | Email delivery issues |

## Responsive Design

```
Desktop (≥1024px):
┌──────────────────────────────────────────┐
│ System Alerts                            │
├──────────────────────────────────────────┤
│ [Dot] Title           [Severity] [Status]│
│       Description                        │
│       Service: ...                       │
├──────────────────────────────────────────┤
│ [Dot] Title           [Severity] [Status]│
│       Description                        │
│       Service: ...                       │
└──────────────────────────────────────────┘

Tablet (≥768px):
┌────────────────────────────┐
│ System Alerts              │
├────────────────────────────┤
│ [Dot] Title                │
│ [Severity] [Status]        │
│ Description                │
├────────────────────────────┤
│ [Dot] Title                │
│ [Severity] [Status]        │
│ Description                │
└────────────────────────────┘

Mobile (<768px):
┌──────────────────┐
│ System Alerts    │
├──────────────────┤
│ [Dot] Title      │
│ [Severity] [Status]
│ Description      │
└──────────────────┘
```

---

## Animation & Interaction

### Hover Effects
```css
.alert-item:hover {
  background-color: rgba(0,0,0,0.02);
  transition: background-color 0.2s;
}
```

### Color Transitions
```css
/* Severity dot smoothly scales on hover */
.severity-dot {
  transition: transform 0.2s;
}

.alert-item:hover .severity-dot {
  transform: scale(1.2);
}
```

### Badge Styling
- Destructive: Red background, white text (for Critical/High)
- Default: Gray background, dark text (for Medium status)
- Secondary: Light gray, for Low severity
- Outline: Border only, for status badges

---

## Summary

The System Alerts implementation provides:

✅ **Visual Clarity:** Color-coded by severity (red, orange, yellow, blue)
✅ **Information Density:** Shows title, description, service, severity, status
✅ **Admin-Only View:** Secure, role-based access control
✅ **Responsive Design:** Works on desktop, tablet, and mobile
✅ **Real-Time:** Fetched dynamically from backend
✅ **Scalable:** Handles up to 20 alerts, displays top 6
✅ **User-Friendly:** Clear status badges and descriptions
✅ **Professional:** Matches dashboard design language

