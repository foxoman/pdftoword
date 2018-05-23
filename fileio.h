#pragma once
#include <QObject>

class FileIO : public QObject {
    Q_OBJECT

    public:
    Q_PROPERTY (QString source READ source WRITE setSource NOTIFY sourceChanged)
    explicit FileIO (QObject* parent = Q_NULLPTR);

    Q_INVOKABLE QString read ();
    Q_INVOKABLE bool write (const QString& data);

    QString source () {
        return mSource;
    }

    public slots:
    void setSource (const QString& source) {
        mSource = source;
    }

    signals:
    void sourceChanged (const QString& source);
    void error (const QString& msg);

    private:
    QString mSource;
    Q_DISABLE_COPY (FileIO)
};
