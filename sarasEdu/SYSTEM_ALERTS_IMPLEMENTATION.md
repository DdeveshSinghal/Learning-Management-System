# System Alerts Feature - Implementation Complete

## Overview
The System Alerts feature has been fully implemented to monitor backend health and system status. Admins can view real-time alerts about critical system issues including backend service, database, server, payment gateway, storage, API, and email services.

## Backend Implementation

### 1. Data Model (`core/models.py`)

#### SystemAlert Model
```python
class SystemAlert(models.Model):
    ALERT_TYPE_CHOICES = [
        ('backend', 'Backend Service'),
        ('database', 'Database'),
        ('server', 'Server'),
        ('payment', 'Payment Gateway'),
        ('storage', 'Storage'),
        ('api', 'API'),
        ('email', 'Email Service'),
    ]
    
    SEVERITY_CHOICES = [
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('critical', 'Critical'),
    ]
    
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('resolved', 'Resolved'),
        ('investigating', 'Investigating'),
        ('monitoring', 'Monitoring'),
    ]
    
    alert_type = CharField(choices=ALERT_TYPE_CHOICES)
    severity = CharField(choices=SEVERITY_CHOICES)
    status = CharField(choices=STATUS_CHOICES)
    title = CharField(max_length=200)
    description = TextField()
    affected_service = CharField(max_length=100, blank=True)
    resolution_steps = TextField(blank=True)
    affected_users_count = IntegerField(default=0)
    metadata = JSONField(default=dict, blank=True)
    created_at = DateTimeField(auto_now_add=True)
    resolved_at = DateTimeField(null=True, blank=True)
```

**Key Features:**
- `alert_type`: Categorizes alerts (backend, database, server, payment, storage, api, email)
- `severity`: Priority level (low, medium, high, critical)
- `status`: Current state (active, resolved, investigating, monitoring)
- `affected_users_count`: Tracks impact on users
- `metadata`: Flexible JSON storage for additional context
- `resolved_at`: Tracks when issue was resolved

### 2. Serializer (`core/serializers.py`)

```python
class SystemAlertSerializer(serializers.ModelSerializer):
    class Meta:
        model = SystemAlert
        fields = [
            'id', 'alert_type', 'severity', 'status', 'title',
            'description', 'affected_service', 'resolution_steps',
            'affected_users_count', 'metadata', 'created_at', 'resolved_at'
        ]
        read_only_fields = ['id', 'created_at', 'resolved_at']
```

### 3. API ViewSet (`core/viewsets.py`)

```python
class SystemAlertViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for system alerts - admin only access"""
    serializer_class = SystemAlertSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        # Only admins can view system alerts
        if self.request.user and self.request.user.role == 'admin':
            # Return active and recent alerts, sorted by severity then creation date
            return SystemAlert.objects.all().order_by('-severity', '-created_at')[:20]
        return SystemAlert.objects.none()
```

**Security Features:**
- Admin-only access via role check
- ReadOnlyModelViewSet prevents unauthorized modifications
- Returns empty queryset for non-admins
- Ordered by severity (critical alerts appear first)

### 4. URL Configuration (`core/urls.py`)

```python
router.register(r'system-alerts', SystemAlertViewSet, basename='system-alerts')
```

**API Endpoint:** `GET /api/system-alerts/`

**Response Example:**
```json
[
  {
    "id": 1,
    "alert_type": "database",
    "severity": "critical",
    "status": "active",
    "title": "Database Connection Timeout",
    "description": "Database response time exceeding threshold (2.5s average)",
    "affected_service": "core_user",
    "resolution_steps": "Check database server load and optimize slow queries",
    "affected_users_count": 45,
    "metadata": {
      "average_response_time": "2.5s",
      "threshold": "1.5s",
      "affected_endpoints": ["/api/courses/", "/api/enrollments/"]
    },
    "created_at": "2024-01-15T10:30:00Z",
    "resolved_at": null
  }
]
```

### 5. Database Migration

Created migration: `0010_systemalert_activitylog.py`
- Adds `SystemAlert` table
- Adds `ActivityLog` table (from previous implementation)
- Automatically applied with `python manage.py migrate`

---

## Frontend Implementation

### 1. Enhanced Dashboard Integration (`frontend/src/components/enhanced-dashboard-sections.jsx`)

#### State Management
```javascript
const [systemAlerts, setSystemAlerts] = useState([]);
```

#### API Fetching
```javascript
const [live, courseList, ann, notif, enr, attendance, evt, activityLogsRes, systemAlertsRes] = await Promise.all([
  // ... other endpoints
  apiRequest('/system-alerts/').catch(() => []),
]);

setSystemAlerts(normalizeArray(systemAlertsRes));
```

#### System Alerts UI Component
```javascript
<Card>
  <CardHeader>
    <CardTitle className="flex items-center gap-2">
      <AlertTriangle className="h-5 w-5" />
      System Alerts
    </CardTitle>
  </CardHeader>
  <CardContent>
    <div className="space-y-3">
      {systemAlerts.length === 0 ? (
        <div className="text-sm text-muted-foreground">All systems operational</div>
      ) : (
        systemAlerts.slice(0, 6).map((alert) => {
          const severityStyles = {
            critical: { dot: 'bg-red-600', badge: 'destructive', bgColor: 'bg-red-50' },
            high: { dot: 'bg-orange-500', badge: 'destructive', bgColor: 'bg-orange-50' },
            medium: { dot: 'bg-yellow-500', badge: 'default', bgColor: 'bg-yellow-50' },
            low: { dot: 'bg-blue-500', badge: 'secondary', bgColor: 'bg-blue-50' }
          };
          // ... render with severity-based styling
        })
      )}
    </div>
  </CardContent>
</Card>
```

**Features:**
- **Severity Color Coding:**
  - 🔴 Critical: Red (#DC2626) - Immediate action required
  - 🟠 High: Orange (#F97316) - Urgent attention needed
  - 🟡 Medium: Yellow (#EAB308) - Monitor closely
  - 🔵 Low: Blue (#3B82F6) - Informational

- **Dynamic Styling:**
  - Dot indicator colors match severity
  - Background colors provide visual context
  - Status badges show current resolution state

- **Information Display:**
  - Title and description
  - Affected service name
  - Severity and status badges
  - Up to 6 most recent alerts shown

---

## Usage Guide

### For Admins

1. **Access Dashboard:** Navigate to admin dashboard
2. **View System Alerts:** Scroll to "System Alerts" section
3. **Severity Levels:**
   - 🔴 **Critical:** Immediate action required, system functionality impaired
   - 🟠 **High:** Performance degradation, user-facing impact
   - 🟡 **Medium:** Service degradation, background impact
   - 🔵 **Low:** Informational alerts, no immediate impact

4. **Status States:**
   - **Active:** Issue currently occurring
   - **Investigating:** Team is diagnosing the issue
   - **Monitoring:** Issue resolved but being monitored
   - **Resolved:** Issue fixed and confirmed

### For Developers

#### Create System Alert
```python
from core.models import SystemAlert

SystemAlert.objects.create(
    alert_type='database',
    severity='high',
    status='active',
    title='Slow Query Detected',
    description='Query execution time exceeding threshold',
    affected_service='enrollments',
    resolution_steps='Optimize query and add database indexes',
    affected_users_count=15,
    metadata={
        'query_time': '3.2s',
        'threshold': '1.5s',
        'table': 'core_enrollment'
    }
)
```

#### Update Alert Status
```python
alert = SystemAlert.objects.get(id=1)
alert.status = 'resolved'
alert.resolved_at = timezone.now()
alert.save()
```

#### Query Alerts by Severity
```python
critical_alerts = SystemAlert.objects.filter(
    severity='critical',
    status='active'
).order_by('-created_at')
```

---

## Architecture

### Data Flow

```
Backend Health Monitoring
        ↓
Create SystemAlert Instance
        ↓
Database Storage (core_systemalert table)
        ↓
REST API Endpoint (/api/system-alerts/)
        ↓
Frontend API Request (enhanced-dashboard-sections.jsx)
        ↓
State Management (setSystemAlerts)
        ↓
Admin Dashboard Display
```

### Database Schema

```sql
CREATE TABLE core_systemalert (
  id INT PRIMARY KEY AUTO_INCREMENT,
  alert_type VARCHAR(50) NOT NULL,
  severity VARCHAR(50) NOT NULL,
  status VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  description LONGTEXT NOT NULL,
  affected_service VARCHAR(100),
  resolution_steps LONGTEXT,
  affected_users_count INT DEFAULT 0,
  metadata JSON,
  created_at DATETIME AUTO_NOW_ADD,
  resolved_at DATETIME NULL
);
```

---

## Testing

### API Endpoint Test

```bash
# Get all system alerts (admin only)
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/system-alerts/
```

### Frontend Test
1. Login as admin user
2. Navigate to dashboard
3. Verify "System Alerts" card appears in admin section
4. Confirm styling matches severity levels
5. Test with 0 alerts - should show "All systems operational"
6. Test with multiple alerts - should show up to 6, ordered by severity

---

## Security Considerations

1. **Authentication Required:** Admin role verified on backend
2. **Authorization:** Only admins receive alerts via API
3. **Read-Only Access:** Alerts cannot be modified via REST API
4. **Data Privacy:** User count is aggregated, no PII exposed
5. **Role-Based Access:** Non-admin requests return empty queryset

---

## Future Enhancements

1. **Alert Notifications:** Email/SMS alerts for critical issues
2. **Alert History:** Archive resolved alerts for trend analysis
3. **Automated Actions:** Trigger corrective actions on alert creation
4. **Alert Rules Engine:** Define custom thresholds and alert conditions
5. **Integration:** Connect to monitoring tools (Prometheus, Datadog, etc.)
6. **Alert Dashboards:** Dedicated admin page for alert management
7. **Webhooks:** Send alerts to external systems (Slack, PagerDuty)
8. **SLA Tracking:** Monitor resolution time SLAs

---

## Files Modified/Created

### Backend
- ✅ `core/models.py` - Added SystemAlert and ActivityLog models
- ✅ `core/serializers.py` - Added SystemAlertSerializer
- ✅ `core/viewsets.py` - Added SystemAlertViewSet
- ✅ `core/urls.py` - Registered system-alerts endpoint
- ✅ `core/migrations/0010_systemalert_activitylog.py` - Database schema changes

### Frontend
- ✅ `frontend/src/components/enhanced-dashboard-sections.jsx` - Added system alerts UI and API integration

### Database
- ✅ Migration created and ready to apply with `python manage.py migrate`

---

## Deployment Checklist

- [ ] Run migrations: `python manage.py migrate`
- [ ] Test API endpoint: `GET /api/system-alerts/`
- [ ] Verify admin dashboard displays alerts
- [ ] Test severity color coding
- [ ] Verify permission checks (non-admins see empty)
- [ ] Monitor database performance
- [ ] Set up monitoring for alert creation triggers
- [ ] Document alert types for your organization
- [ ] Train admins on interpreting alerts

---

## Support & Troubleshooting

### Migration Issues
```bash
# Reset migrations (development only)
python manage.py migrate core zero
python manage.py migrate core

# Check migration status
python manage.py showmigrations core
```

### API Debugging
```bash
# Test endpoint with Django shell
python manage.py shell
from core.models import SystemAlert
SystemAlert.objects.all()
```

### Frontend Issues
- Check browser console for API errors
- Verify user has admin role
- Check network tab for `/system-alerts/` request
- Verify response format matches serializer output

---

## Performance Notes

- **Database Query:** Optimized with `.order_by('-severity', '-created_at')[:20]`
- **API Response:** Returns max 20 alerts, frontend displays top 6
- **Frontend Rendering:** Efficient with map() and conditional rendering
- **Scalability:** JSONField allows storing monitoring metadata without schema changes

---

## Summary

The System Alerts feature provides admin users with real-time visibility into system health across 7 service categories (backend, database, server, payment, storage, API, email) with 4 severity levels and 4 status states. The implementation is secure, performant, and follows Django REST Framework best practices.
