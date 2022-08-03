# EFT Setup

As integration must be triggered in POS, all integrations must be linked to payment methods used in POS. This linking of EFT integrations and POS payment methods is done in **EFT Setup** page. Based on these links, the POS will invoke the EFT framework depending on which payment methods are being used on which POS Units.

![eft_setup](../images/EFT%20setup.png)

For every POS payment method which needs to trigger integration, needs to be attached **EFT Integration type**. In case that there is more integration types used on different POS units, then there is need to be set up more lines with same payment method but different POS unit and integration type. In cases when there is no assigned POS unit in line, all POS units without specific setup will have the same integration type.

In setup on the above example, if user try to pay with payment method "T" on POS unit 3, it will be used **MOCK_CLIENT_SIDE** type of integration, but in case that user try to pay with same payment method **T** on POS unit 2, **FLEXIITERM** integration type will be used.