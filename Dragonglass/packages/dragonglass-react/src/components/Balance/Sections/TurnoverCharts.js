import React from "react";
import { Bar, Pie } from "react-chartjs-2";
import { localize } from "../../LocalizationManager";
import { motion } from "framer-motion";

export default function TurnoverChart({ layout, data, height, isSingle, delay }) {
  let labels = [];
  let values = [];

  layout.subsections.forEach((subsection) => {
    subsection.fields.forEach((field) => {
      if (field.select !== "profitPct") {
        labels.push(localize(field.label));
        values.push(data[subsection.select][field.select]);
      }
    });
  });

  const chartData = {
    labels: labels,
    datasets: [
      {
        label: "Turnover amount",
        data: values,
        backgroundColor: [
          "rgba(255, 99, 132, 0.2)",
          "rgba(54, 162, 235, 0.2)",
          "rgba(255, 206, 86, 0.2)",
          "rgba(75, 192, 192, 0.2)",
          "rgba(153, 102, 255, 0.2)",
          "rgba(255, 159, 64, 0.2)",
          "rgba(255, 10, 104, 0.2)",
          "rgba(40, 180, 0, 0.2)",
        ],
        borderColor: [
          "rgba(255, 99, 132, 1)",
          "rgba(54, 162, 235, 1)",
          "rgba(255, 206, 86, 1)",
          "rgba(75, 192, 192, 1)",
          "rgba(153, 102, 255, 1)",
          "rgba(255, 159, 64, 1)",
          "rgba(255, 10, 104, 1)",
          "rgba(40, 180, 0, 1)",
        ],
        borderWidth: 1,
      },
    ],
  };

  const pieChartLabels = [
    localize(
      layout.subsections
        .filter((subsection) => subsection.select === "profit")[0]
        .fields.filter((field) => field.select === "profitPct")[0].label
    ),
    "Turnover %",
  ];

  const pieChartData = {
    labels: pieChartLabels,
    datasets: [
      {
        label: "Profit",
        data: [data.profit.profitPct, 100 - data.profit.profitPct],
        backgroundColor: ["rgba(60, 200, 80, 0.2)", "rgba(54, 162, 235, 0.2)"],
        borderColor: ["rgba(60, 200, 80, 1)", "rgba(54, 162, 235, 1)"],
        borderWidth: 1,
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
    <div className={`charts ${isSingle ? "charts--single" : ""}`}>
      <div className="charts__container charts__container--bar">
        <motion.div
          className="charts__connector"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1, transition: { delay: delay } }}
        />
        <motion.div
          className="charts__chart charts__chart--bar"
          initial={{ position: "relative", top: -40, opacity: 0 }}
          animate={{ top: 0, opacity: 1, transition: { ease: [0.34, 1.56, 0.64, 1], delay: delay } }}
        >
          <Bar options={options} data={chartData} height={height} />
        </motion.div>
      </div>
      <div className="charts__container charts__container--pie">
        <motion.div
          className="charts__connector"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1, transition: { delay: delay } }}
        />
        <motion.div
          className="charts__chart charts__chart--pie"
          initial={{ position: "relative", top: -40, opacity: 0 }}
          animate={{ top: 0, opacity: 1, transition: { ease: [0.34, 1.56, 0.64, 1], delay: delay + 0.1 } }}
        >
          <Pie options={options} data={pieChartData} height={height} />
        </motion.div>
      </div>
    </div>
  );
}
