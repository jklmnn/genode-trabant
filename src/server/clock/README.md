
# Clock server

The clock provides an RTC session proxy. It syncs on start and one hour later to calculate its local clock skew.
It then provides a RTC session based on the local timer and a skew correction. Every 24 hours it syncs again to keep its time correct.

**NOTE: this is still experimental, clock correctness over long times, especially more than 24h, cannot be guaranteed**

Example: [clock.run](https://github.com/jklmnn/genode-trabant/blob/master/run/clock.run)
