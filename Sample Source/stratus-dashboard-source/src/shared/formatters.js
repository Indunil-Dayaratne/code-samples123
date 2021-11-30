import Vue from 'vue';

export function formatNumber(value) {
  if (typeof value !== "number") {
    return value;
  }

  var formatter = new Intl.NumberFormat('en-US', {
    style: 'decimal',
    maximumFractionDigits: 0,
    minimumFractionDigits: 0
  });

  return formatter.format(value);
}

Vue.prototype.$formatNumber = formatNumber;

Vue.filter('toDecimal', function (value) {
  if (typeof value !== "number") {
    return value;
  }

  var formatter = new Intl.NumberFormat('en-US', {
    style: 'decimal',
    maximumFractionDigits: 2,
    minimumFractionDigits: 2
  });
  return formatter.format(value);
});

Vue.filter('toNumber', function (value, decimalPlaces = 0) {
  
  if (typeof value !== 'number' || Number.isNaN(Number.parseFloat(value))) {
    return value;
  }
  
  var number = parseFloat(value);

  if (typeof number !== "number") {
    return value;
  }

  var formatter = new Intl.NumberFormat('en-US', {
    style: 'decimal',
    maximumFractionDigits: decimalPlaces,
    minimumFractionDigits: decimalPlaces
  });

  return formatter.format(number);
});