#! /bin/sh

### BEGIN INIT INFO
# Provides:		autossh
# Required-Start:	$remote_fs $syslog $network
# Required-Stop:	$remote_fs $syslog
# Default-Start:	2 3 4 5
# Default-Stop:		
# Short-Description:	Autossh for isuma
### END INIT INFO

set -e

umask 022

if test -f /etc/default/isuma-autossh; then
    . /etc/default/isuma-autossh
fi

. /lib/lsb/init-functions

export PATH=/sbin:/bin:/usr/sbin:/usr/bin

case "$1" in
  start)
	log_daemon_msg "Starting Autossh for isuma" "autossh"
	if start-stop-daemon --quiet --start --background --pidfile /var/run/autossh-isuma.pid --make-pidfile --exec /usr/bin/autossh -- $AUTOSSH_ISUMA_OPTS; then
	    log_end_msg 0
	else
	    log_end_msg 1
	fi
	;;
  stop)
	log_daemon_msg "Stopping Autossh for isuma" "autossh"
	if start-stop-daemon --stop --quiet --pidfile /var/run/autossh-isuma.pid ; then
	    log_end_msg 0
	else
	    log_end_msg 1
	fi
	;;

  reload|force-reload)
	log_daemon_msg "Reloading Autossh for isuma's configuration" "autossh"
	if start-stop-daemon --stop --signal 1 --quiet --oknodo --pidfile /var/run/autossh-isuma.pid; then
	    log_end_msg 0
	else
	    log_end_msg 1
	fi
	;;

  restart)
	log_daemon_msg "Restarting Autossh for isuma" "autossh"
	start-stop-daemon --stop --quiet --oknodo --retry 30 --pidfile /var/run/autossh-isuma.pid
	if start-stop-daemon --start --quiet -b --make-pidfile  --pidfile /var/run/autossh-isuma.pid --exec /usr/bin/autossh -- $AUTOSSH_ISUMA_OPTS; then
	    log_end_msg 0
	else
	    log_end_msg 1
	fi
	;;

  try-restart)
	log_daemon_msg "Restarting Autossh for isuma" "autossh"
	set +e
	start-stop-daemon --stop --quiet --retry 30 --pidfile /var/run/autossh-isuma.pid
	RET="$?"
	set -e
	case $RET in
	    0)
		# old daemon stopped
		if start-stop-daemon --start --quiet --oknodo -b --pidfile /var/run/autossh-isuma.pid --make-pidfile --exec /usr/bin/autossh -- $AUTOSSH_ISUMA_OPTS; then
		    log_end_msg 0
		else
		    log_end_msg 1
		fi
		;;
	    1)
		# daemon not running
		log_progress_msg "(not running)"
		log_end_msg 0
		;;
	    *)
		# failed to stop
		log_progress_msg "(failed to stop)"
		log_end_msg 1
		;;
	esac
	;;

  status)
    status_of_proc -p /var/run/autossh-isuma.pid /usr/sbin/autossh autossh && exit 0 || exit $?
	;;

  *)
	log_action_msg "Usage: /etc/init.d/isuma-autossh {start|stop|reload|force-reload|restart|try-restart|status}"
	exit 1
esac

exit 0
