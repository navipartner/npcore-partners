import React from "react";
import { Doughnut } from "react-chartjs-2";
import { localize } from "../../LocalizationManager";
import { motion } from "framer-motion";

export default function DiscountChart({ layout, data, delay, isSingle, height }) {
  let labels = [];
  let chartData = [];

  layout.subsections
    .filter((subsection) => subsection.select === "discountAmounts")[0]
    .fields.forEach((field) => {
      labels.push(localize(field.label));
      chartData.push(data.discountAmounts[field.select]);
    });

  const pieChartData = {
    labels: labels,
    datasets: [
      {
        label: "Discounts",
        data: chartData,
        backgroundColor: [
          "rgba(255, 99, 132, 0.2)",
          "rgba(54, 162, 235, 0.2)",
          "rgba(255, 206, 86, 0.2)",
          "rgba(152, 235, 69, 0.2)",
          "rgba(153, 102, 255, 0.2)",
          "rgba(255, 10, 104, 0.2)",
          "rgba(75, 192, 192, 0.2)",
        ],
        borderColor: [
          "rgba(255, 99, 132, 1)",
          "rgba(54, 162, 235, 1)",
          "rgba(255, 206, 86, 1)",
          "rgba(152, 235, 69, 1)",
          "rgba(153, 102, 255, 1)",
          "rgba(255, 10, 104, 1)",
          "rgba(75, 192, 192, 1)",
        ],
        borderWidth: 1,
        tension: 0.3,
      },
    ],
  };

  const style = getComputedStyle(document.body);
  const textColor = style.getPropertyValue("--color-text-100");
  const fontSize = isSingle ? 11 : 9;

  const options = {
    maintainAspectRatio: false,
    plugins: {
      legend: {
        labels: {
          color: textColor,
          usePointStyle: true,
          font: {
            size: fontSize,
          },
        },
      },
    },
    scales: {
      x: {
        ticks: {
          color: textColor,
        },
      },
      y: {
        ticks: {
          color: textColor,
        },
      },
    },
  };

  return (
    <div className={`discount-chart ${isSingle ? "" : "discount-chart--inline-row"}`}>
      <motion.div
        className="discount-chart__connector"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1, transition: { delay: delay } }}
      />
      <motion.div
        className="discount-chart__chart"
        initial={{ position: "relative", top: -40, opacity: 0 }}
        animate={{ top: 0, opacity: 1, transition: { ease: [0.34, 1.56, 0.64, 1], delay: delay } }}
      >
        <Doughnut options={options} data={pieChartData} height={height} width={400} />
      </motion.div>
    </div>
  );
}
