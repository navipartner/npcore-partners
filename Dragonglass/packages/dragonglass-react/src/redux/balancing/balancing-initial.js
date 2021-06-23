import balancingDefaultView from "./balancing-default-view";

export default {
  view: balancingDefaultView,
  caption: "",
  statistics: {
    balancing: {
      createdAt: null,
      directSalescount: 0,
      directItemsReturnLine: 0,
    },
    overview: {
      sales: {
        directItemSalesLcy: 0,
        directItemReturnsLcy: 0,
      },
      cashMovement: {
        localCurrencyLcy: 0,
        foreignCurrencyLcy: 0,
      },
      otherPayments: {
        debtorPaymentLcy: 0,
        eftLcy: 0,
        glPaymentLcy: 0,
      },
      voucher: {
        redeemedVouchersLcy: 0,
        issuedVouchersLcy: 0,
      },
      other: {
        roundingLcy: 0,
        binTransferOutAmountLcy: 0,
        binTransferInAmountLcy: 0,
      },
      creditSales: {
        creditSalesCountLcy: 0,
        creditSalesAmountLcy: 0,
        creditNetSalesAmountLcy: 0,
      },
      details: {
        creditUnrealSaleAmtLcy: 0,
        creditUnrealRetAmtLcy: 0,
        creditRealSaleAmtLcy: 0,
        creditRealReturnAmtLcy: 0,
      },
    },
    discount: {
      discountAmounts: {
        campaignDiscountLcy: 0,
        mixDiscountLcy: 0,
        quantityDiscountLcy: 0,
        customDiscountLcy: 0,
        bomDiscountLcy: 0,
        customerDiscountLcy: 0,
        lineDiscountLcy: 0,
      },
      discountPercent: {
        campaignDiscountPct: 0,
        mixDiscountPct: 0,
        quantityDiscountPct: 0,
        customDiscountPct: 0,
        bomDiscountPct: 0,
        customerDiscountPct: 0,
        lineDiscountPct: 0,
      },
      discountTotal: {
        totalDiscountLcy: 0,
        totalDiscountPct: 0,
      },
    },
    turnover: {
      general: {
        turnoverLcy: 0,
        netTurnoverLcy: 0,
        netCostLcy: 0,
      },
      profit: {
        profitAmountLcy: 0,
        profitPct: 0,
      },
      direct: {
        directTurnoverLcy: 0,
        directNetTurnoverLcy: 0,
      },
      credit: {
        creditTurnoverLcy: 0,
        creditNetTurnoverLcy: 0,
      },
    },
    taxSummary: [],
  },
  cashCount: {
    confirmed: {},
    counting: [],
    closingAndTransfer: [],
  },
};
