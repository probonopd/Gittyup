#ifndef DEBUG_H
#define DEBUG_H

#include <QDebug>

#ifdef DEBUG_OUTPUT_GENERAL
#define Debug(x)                                                               \
  do {                                                                         \
    qDebug() << x;                                                             \
  } while (false)
#else
#define Debug(x)
#endif

#ifdef DEBUG_OUTPUT_REFRESH
#define DebugRefresh(x)                                                        \
  do {                                                                         \
    qDebug() << Q_FUNC_INFO << QStringLiteral(": ") << x;                      \
  } while (false)
#else
#define DebugRefresh(x)
#endif
#endif // DEBUG_H
