# System Alerts - Quick Reference

## Severity Levels & Colors

| Severity | Color | Badge | Meaning | Action |
|----------|-------|-------|---------|--------|
| 🔴 Critical | Red (#DC2626) | destructive | System failure, major impact | Immediate response required |
| 🟠 High | Orange (#F97316) | destructive | Significant degradation | Urgent attention within 1 hour |
| 🟡 Medium | Yellow (#EAB308) | default | Noticeable impact | Address within 24 hours |
| 🔵 Low | Blue (#3B82F6) | secondary | Informational only | Monitor and plan |

## Status States

| Status | Meaning | Next Action |
|--------|---------|------------|
| **Active** | Issue currently occurring | Investigate and resolve |
| **Investigating** | Team is diagnosing | Continue monitoring, update progress |
| **Monitoring** | Issue resolved, being watched | Confirm stability, close alert |
| **Resolved** | Issue fixed and verified | Archive alert, post-mortem if critical |

## Alert Types

| Type | Description | Common Causes |
|------|-------------|---------------|
| **Backend Service** | Application server issues | Crashes, high CPU, memory leak |
| **Database** | Database connection/performance | Slow queries, connection pool exhausted |
| **Server** | Server infrastructure issues | Disk space, CPU overload, network |
| **Payment Gateway** | Payment processing failures | API down, rate limit exceeded |
| **Storage** | File storage system issues | MinIO down, disk full, permissions |
| **API** | API endpoint problems | Timeouts, errors, rate limiting |
| **Email Service** | Email delivery failures | SMTP down, bounce issues |

## API Response Format

```json
{
  "id": 1,
  "alert_type": "database",
  "severity": "critical",
  "status": "active",
  "title": "Database Connection Timeout",
  "description": "Database response time exceeding threshold",
  "affected_service": "core_user",
  "resolution_steps": "Check database server load and optimize queries",
  "affected_users_count": 45,
  "metadata": {
    "average_response_time": "2.5s",
    "threshold": "1.5s",
    "affected_endpoints": ["/api/courses/", "/api/enrollments/"]
  },
  "created_at": "2024-01-15T10:30:00Z",
  "resolved_at": null
}
```

## Creating Alerts (Backend)

### Via Django Shell
```bash
python manage.py shell
```

```python
from core.models import SystemAlert
from django.utils import timezone

# Critical database alert
SystemAlert.objects.create(
    alert_type='database',
    severity='critical',
    status='active',
    title='Database Connection Pool Exhausted',
    description='All connection slots are in use, new connections being rejected',
    affected_service='primary_db',
    resolution_steps='Increase connection pool size or investigate slow queries',
    affected_users_count=120,
    metadata={
        'max_connections': 100,
        'active_connections': 100,
        'queue_size': 45,
        'average_query_time': '3.5s'
    }
)

# High severity API alert
SystemAlert.objects.create(
    alert_type='api',
    severity='high',
    status='investigating',
    title='API Response Time Degradation',
    description='Average response time increased to 2.5s (normal: 200ms)',
    affected_service='course_api',
    resolution_steps='Scale up API servers and clear cache',
    affected_users_count=250,
    metadata={'endpoints': ['GET /api/courses/', 'GET /api/enrollments/']}
)
```

### Via Django Admin
1. Navigate to Django Admin panel
2. Go to Core → System Alerts
3. Click "Add System Alert"
4. Fill in all required fields
5. Click "Save"

## Querying Alerts (Backend)

```python
from core.models import SystemAlert

# Get all critical alerts
critical = SystemAlert.objects.filter(severity='critical')

# Get active alerts by type
db_alerts = SystemAlert.objects.filter(
    alert_type='database',
    status='active'
)

# Get alerts from last 24 hours
from django.utils import timezone
from datetime import timedelta
recent = SystemAlert.objects.filter(
    created_at__gte=timezone.now() - timedelta(hours=24)
)

# Get unresolved alerts
unresolved = SystemAlert.objects.exclude(status='resolved')

# Get alerts affecting most users
high_impact = SystemAlert.objects.filter(
    affected_users_count__gte=50
).order_by('-affected_users_count')
```

## Updating Alert Status

```python
from core.models import SystemAlert
from django.utils import timezone

alert = SystemAlert.objects.get(id=1)

# Mark as investigating
alert.status = 'investigating'
alert.save()

# Mark as resolved
alert.status = 'resolved'
alert.resolved_at = timezone.now()
alert.save()

# Update description with investigation findings
alert.description = 'Database connection pool exhaustion caused by ' \
                   'slow queries on user_stats view. Optimized query.'
alert.status = 'monitoring'
alert.save()
```

## Frontend Integration

### Accessing Alerts in Components

```javascript
import { useEffect, useState } from 'react';
import { request as apiRequest } from '../services/api';

function SystemAlertPanel() {
  const [alerts, setAlerts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiRequest('/system-alerts/')
      .then(data => setAlerts(data.results || data || []))
      .catch(err => {
        console.error('Failed to fetch alerts:', err);
        setAlerts([]);
      })
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div>Loading alerts...</div>;
  if (alerts.length === 0) return <div>All systems operational</div>;

  return (
    <div className="space-y-3">
      {alerts.map(alert => (
        <div key={alert.id} className={`p-3 border rounded-lg bg-${alert.severity}-50`}>
          <h3>{alert.title}</h3>
          <p>{alert.description}</p>
          <span className="text-sm">{alert.severity.toUpperCase()}</span>
        </div>
      ))}
    </div>
  );
}
```

## Monitoring Dashboard Integration

### Display Alert Count by Severity

```javascript
const alertStats = {
  critical: alerts.filter(a => a.severity === 'critical').length,
  high: alerts.filter(a => a.severity === 'high').length,
  medium: alerts.filter(a => a.severity === 'medium').length,
  low: alerts.filter(a => a.severity === 'low').length,
};

// Render as metric cards
<div className="grid grid-cols-4 gap-4">
  <Card><Title>Critical</Title><Count>{alertStats.critical}</Count></Card>
  <Card><Title>High</Title><Count>{alertStats.high}</Count></Card>
  <Card><Title>Medium</Title><Count>{alertStats.medium}</Count></Card>
  <Card><Title>Low</Title><Count>{alertStats.low}</Count></Card>
</div>
```

## Troubleshooting

### API Returns Empty List
- **Cause:** User is not admin
- **Fix:** Verify user role is 'admin' in Django Admin

### Alerts Not Appearing
- **Cause:** No alerts created yet
- **Fix:** Create test alert using shell command above
- **Expected:** Message "All systems operational" when no alerts

### Permission Denied Error
- **Cause:** Token expired or user not authenticated
- **Fix:** Re-login or refresh token

### Database Fields Missing
- **Cause:** Migration not applied
- **Fix:** Run `python manage.py migrate core`

## Severity Guidelines

Use these guidelines when creating alerts:

### 🔴 CRITICAL - Immediate Response (< 15 min)
- Complete service outage
- Data corruption detected
- Security breach happening now
- Payment processing down
- User data loss risk

### 🟠 HIGH - Urgent (< 1 hour)
- Service degradation (>50% slower)
- Increased error rate (>5%)
- Resource exhaustion (CPU >90%, Memory >85%)
- Database replication lag >5 mins
- Payment processing failures (>1%)

### 🟡 MEDIUM - Important (< 24 hours)
- Slow API responses (>1 sec)
- Minor feature failures
- Resource warnings (CPU >70%, Memory >75%)
- Disk space low (>80% used)
- Background job delays

### 🔵 LOW - Informational (No urgency)
- Non-critical service maintenance
- Minor performance variations
- Deprecated feature usage
- Test/staging environment issues
- Informational notifications

## Alert Response Checklist

When you see an alert:

1. **Read the Alert**
   - [ ] Note severity level
   - [ ] Read title and description
   - [ ] Check affected service
   - [ ] Review metadata

2. **Assess Impact**
   - [ ] How many users affected?
   - [ ] Which services impacted?
   - [ ] Is it customer-facing?
   - [ ] Is it revenue-impacting?

3. **Investigate**
   - [ ] Check logs
   - [ ] Review metrics
   - [ ] Test affected functionality
   - [ ] Identify root cause

4. **Respond**
   - [ ] Update alert status to 'investigating'
   - [ ] Apply fix or mitigation
   - [ ] Verify resolution
   - [ ] Update alert with findings

5. **Close**
   - [ ] Mark as 'resolved'
   - [ ] Document lessons learned
   - [ ] Schedule post-mortem if critical
   - [ ] Update runbooks if needed

## Common Alerts & Solutions

### Database Connection Timeout
```
Description: Database response time exceeding threshold
Solution: 
1. Check active connections: SELECT count(*) FROM INFORMATION_SCHEMA.PROCESSLIST
2. Kill slow queries: KILL {process_id}
3. Optimize slow queries or add indexes
4. Increase connection pool if needed
```

### Backend Service Down
```
Description: Health check failed, application not responding
Solution:
1. Check backend logs for errors
2. Verify database connectivity
3. Check disk space
4. Restart backend service if needed
5. Scale up if resource-constrained
```

### API Rate Limited
```
Description: Rate limit threshold exceeded
Solution:
1. Check API traffic patterns
2. Implement caching to reduce requests
3. Increase rate limit if legitimate traffic spike
4. Investigate for DDoS activity
```

### Storage Space Critical
```
Description: Disk space usage above 90%
Solution:
1. Identify large files/old logs
2. Archive old files
3. Clean up unused uploads
4. Scale storage if needed
5. Implement cleanup policies
```

---

## Resources

- API Documentation: `/api/system-alerts/` endpoint
- Model Definition: `core/models.py` - `SystemAlert` class
- Serializer: `core/serializers.py` - `SystemAlertSerializer`
- ViewSet: `core/viewsets.py` - `SystemAlertViewSet`
- Frontend: `frontend/src/components/enhanced-dashboard-sections.jsx`
