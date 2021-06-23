import { INVOCATION_SUCCESSFUL, SKIPPED_BUSY, REJECTED_DUPLICATE, REJECT_DUPLICATE_THRESHOLD } from "dragonglass-nav";
import { NAVEventFactory } from "dragonglass-nav";

export const testEvents = () => {
    const event1 = NAVEventFactory.event("__mockEvent1");
    const event2 = NAVEventFactory.event({ name: "__mockEvent2", skipIfBusy: true });
    const event3 = NAVEventFactory.event({ name: "__mockEvent3", rejectDuplicate: true });

    const method1 = NAVEventFactory.method("Method1");
    const method2 = NAVEventFactory.method({ name: "__mockMethod2", skipIfBusy: true });
    const method3 = NAVEventFactory.method({ name: "__mockMethod3", rejectDuplicate: true });
    const method4 = NAVEventFactory.method({
        name: "__mockMethod4",
        callback: (args) => console.log("Method4 callback gives " + JSON.stringify(args))
    });
    const method5 = NAVEventFactory.method({
        name: "__mockMethod4",
        processArguments: args => ({ ...args, method5: "additional" }),
        callback: args => console.log("Method5 callback gives " + JSON.stringify(args))
    });

    var promises = [];
    for (let i = 0; i < 10; i++) {
        promises.push(event1.raise({ iteration: i }));
        promises.push(event2.raise({ iteration: i }));
        promises.push(event3.raise({ iteration: i }));
        promises.push(method1.raise({ iteration: i }));
        promises.push(method2.raise({ iteration: i }));
        promises.push(method3.raise({ iteration: i }));
        promises.push(method4.raise({ iteration: i }));
        promises.push(method5.raise({ iteration: i }));
    }

    promises.forEach(p => p.then(r => console.log(`Result: ${r.toString()}`)));

    Promise.all(promises)
        .then(() => console.log("All tests done."))
        .then(() => {
            console.log("Testing SkipIfBusy");

            const expect = (actual, expected, id) => {
                if (actual === expected)
                    return console.log(`Expect ok${id ? " " + id : ""}.`);
                throw new Error(`Expected ${expected.toString()} and received ${actual.toString()} for ${id ? " " + id : ""}`);
            };

            method2.raise({}).then(r => expect(r, INVOCATION_SUCCESSFUL));
            method2.raise({}).then(r => expect(r, SKIPPED_BUSY));
            method2.raise({}).then(r => expect(r, SKIPPED_BUSY));
            method2.raise({}).then(r => expect(r, SKIPPED_BUSY));
            method2.raise({}).then(r => expect(r, SKIPPED_BUSY))

                .then(() => {
                    setTimeout(() => {
                        console.log("Testing SkipIfBusy after timeout, all should succeed");

                        method2.raise({})
                            .then(r => expect(r, INVOCATION_SUCCESSFUL))
                            .then(() => {
                                method2.raise({})
                                    .then(r => expect(r, INVOCATION_SUCCESSFUL))
                                    .then(() => {
                                        method2.raise({})
                                            .then(r => expect(r, INVOCATION_SUCCESSFUL))
                                            .then(() => {
                                                method2.raise({})
                                                    .then(r => expect(r, INVOCATION_SUCCESSFUL))
                                                    .then(() => {
                                                        method2.raise({})
                                                            .then(r => expect(r, INVOCATION_SUCCESSFUL))
                                                            .then(() => {
                                                                console.log("All fine.");
                                                                testRejectDuplicate();
                                                            });
                                                    });
                                            });
                                    });
                            });
                    }, 1000);
                });

            const testRejectDuplicate = () => {
                console.log("Test RejectDuplicate");
                method3.raise({}).then(r => expect(r, INVOCATION_SUCCESSFUL, "a"));
                method3.raise({}).then(r => expect(r, REJECTED_DUPLICATE, "b"));
                method3.raise({}).then(r => expect(r, REJECTED_DUPLICATE, "c"));
                method3.raise({}).then(r => expect(r, REJECTED_DUPLICATE, "d"))

                    .then(() => {
                        console.log("Test RejectDuplicate after timeout, first should succeed, two should fail")
                        setTimeout(() => {
                            method3.raise({}).then(r => expect(r, INVOCATION_SUCCESSFUL));
                            setTimeout(() => method3.raise({}).then(r => expect(r, REJECTED_DUPLICATE)), 100);
                            setTimeout(() => method3.raise({}).then(r => expect(r, REJECTED_DUPLICATE))

                                .then(() => {
                                    setTimeout(() => {
                                        console.log("Test RejectDuplicate after long enough timeout, all should succeed")
                                        setTimeout(() => {
                                            method3.raise({}).then(r => expect(r, INVOCATION_SUCCESSFUL));
                                            setTimeout(() => {
                                                method3.raise({}).then(r => expect(r, INVOCATION_SUCCESSFUL));
                                                setTimeout(() => {
                                                    method3.raise({}).then(r => expect(r, INVOCATION_SUCCESSFUL))
                                                        .then(() => {
                                                            setTimeout(() => {
                                                                console.log("Test RejectDuplicates with not really duplicates in there");
                                                                method3.raise({ a: 1 }).then(r => expect(r, INVOCATION_SUCCESSFUL, "a"));
                                                                method3.raise({ a: 2 }).then(r => expect(r, INVOCATION_SUCCESSFUL, "b"));
                                                                method3.raise({ a: 1 }).then(r => expect(r, INVOCATION_SUCCESSFUL, "c"));
                                                                method3.raise({ a: 2 }).then(r => expect(r, INVOCATION_SUCCESSFUL, "d"))

                                                                    .then(() => {
                                                                        console.log("All fine again.");
                                                                    });

                                                            }, 1000);
                                                        })
                                                }, REJECT_DUPLICATE_THRESHOLD);
                                            }, REJECT_DUPLICATE_THRESHOLD);
                                        }, 1000);
                                    }, 1000);
                                }), 200);

                        }, 1000);
                    });
            };
        });
};