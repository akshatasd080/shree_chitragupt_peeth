# Backend: account deletion endpoint

The Android app calls this when the user taps **Profile → Delete Account**:

```
DELETE /api/auth/delete-account
Authorization: Bearer <token>
```

If `DELETE` is not supported, the app retries:

```
POST /api/auth/delete-account
Authorization: Bearer <token>
```

## Expected behaviour

1. Authenticate the Bearer token
2. Delete the user row and associated personal data (or anonymize where legally required)
3. Return `200` with JSON such as `{ "message": "Account deleted" }`
4. Invalid/missing token → `401`

## Minimal Express-style sketch

```js
router.delete('/auth/delete-account', requireAuth, async (req, res) => {
  await User.destroy({ where: { id: req.user.id } });
  // also remove related bookings/messages if they contain PII
  res.json({ message: 'Account deleted' });
});
```

Until this endpoint exists, the app still complies with Play’s *request* path by offering the hosted `delete-account` web page and support email.
