# POS stores

The POS store is highest level in setup for stores. It corresponds to a physical store, and thus the POS store setup performed in NP Retail should match the specifics of the physical store. 

The **POS Store Card** provides an option to create different setups for different stores. Other than the basic store information, such as its name, address, register number, and contacts, each store can have different dimensions, locations and posting rules. Additionally, depending on the assigned **POS Posting Profile**, different POS stores can have different **General Business Posting Groups**, **VAT Business Posting Groups**, **Source Codes**, **Posting Compression**, and different accounts for rounding and differences.

After the POS store and POS units are created, the correlation between them needs to be established. Every POS unit has to be attached to a POS store. A single POS store can have multiple POS units, but a POS unit can be attached to only one POS store.

![pos_store_pos_unit](../images/POS%20store%20vs%20pos%20unit.png)

POS stores can also have different accounts for postings of payments which can be regulated in the [POS posting setup](../explanation/POS_posting_setup.md).

### Related links

- [Create new POS store](../howto/Create_new_POS_store.md)
- [POS units](../explanation/POSUnit.md)
- [POS posting setup](../explanation/POS_posting_setup.md)
- [POS Posting Setup](POS_posting_setup.md)
- [Set up the POS Posting Profile](../howto/POS_Pos_Prof.md)