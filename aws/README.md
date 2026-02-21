# AWS 서버리스 (리마인더 스케줄러 + 푸시)

8단계에서 구현 예정.

- Lambda: 다가오는 리마인더 조회 → FCM 푸시 → notification_logs 기록
- API Gateway: POST /push/register, /push/unregister, /scheduler/run
- EventBridge Scheduler: 분 단위로 /scheduler/run 호출
