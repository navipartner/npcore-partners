# POS store

POS store is highest level in setup for stores. Before POS units and setups for postings are done, POS stores have to be created. POS store we can imagine as physical store and depending on specifics of store all setups for POS store should be done.

POS store card give us oportunity to create different setups for different stores. Except basic information about store (name, address, registar no, contacts), every store can have different dimensions, locations and different rulles for postings. Depending on **POS posting profile** assigned on POS store, different POS stores can have different **General business posting groups**, **VAT business posting groups**, **Source codes**, **Posting compression**, diferent accounts for rounding and differences.

After POS store and POS units are created, corelation between those have to be made. Every POS unit has to be attached to some POS store. One POS store can have many POS units, but POS unit can be attached only to one POS store.

![pos_store_pos_unit](../images/POS%20store%20vs%20pos%20unit.png)

POS stores also can have different accounts for postings of payments which can be regulated in [POS posting setup](../explanation/POS_posting_setup.md)

### Related links

- [Create new POS store](../howto/Create_new_POS_store.md)
- [POS units](../explanation/POSUnit.md)
- [POS posting setup](../explanation/POS_posting_setup.md)