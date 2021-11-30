export class NodeResult {
    id;
    name;
    perspective;
    createdOn;
    returnPeriods = [];
    currencies = [];
    metrics = [];
    exports = [];
    structure = {};
    options = {
        model: [],
        country: [],
        area: [],
        subArea: []
    };

    constructor({ id, createdOn, returnPeriods, currencies, metrics, exports, structure, options }) {
        this.id = id;
        this.structure = structure;
        const node = this.node();
        this.name = node && node.data ? node.data.name : null;
        this.perspective = node && node.data 
            ? node.data.objType && node.data.objType.toLowerCase() === 'layer'
                ? node.data.layer_type || 'ceded'
                : 'gross'
            : '';
        this.createdOn = createdOn;
        this.returnPeriods = returnPeriods;
        this.currencies = currencies;
        this.metrics = metrics.map(metric => ({...metric, nodeId: id, nodeName: this.name, perspective: this.perspective }));
        this.exports = exports;
        this.options = options;
    };

    node(id) {
        if(!id) id = this.id;
        let node = this.structure.inputs.find(x => x.id === id);
        if(!node) node = this.structure.layers.find(x => x.id === id);
        if(!node) return null;
        return node;
    }

    baseNodeId(id) {
        if(!id) id = this.id;
        const node = this.node(id);
        if(node.data.objType === 'input') return id;
        if(node.data.layer_type === 'ceded') return id;
        const baseNode = this.structure.layers.find(x => x.data.layer_group_id === node.data.layer_group_id && x.data.layer_type === 'ceded');
        if(!baseNode) return id;
        return baseNode.id;
    }

    baseCurrency() {
        let node = this.node();
        return node.data.currency;
    }

    baseLossView() {
        for (let i = 0; i < this.structure.data.lossViews.length; i++) {
            const lv = this.structure.data.lossViews[i];
            if(lv) return lv;
        }
    }

    getMetric({metric, getValue, value}, currency, { lossViewIdentifier, aggregationMethod, model, country, area, subArea }) {
        const filtered = this.metrics.find(x => {
            return x.lossView.identifier === lossViewIdentifier
                && x.currency == currency
                && x.aggregationMethod == aggregationMethod
                && x.model == model
                && x.country == country
                && x.area == area
                && x.subArea == subArea;
        });
        if(!filtered) return null;

        return filtered[metric].find(x => getValue(x) === value);
    }

    getReturnPeriod(returnPeriod, currency, { lossView, aggregationMethod, model, country, area, subArea }) {
        return this.getMetric({metric: 'returnPeriods', getValue: (x) => x.returnPeriod, value: returnPeriod}, 
            currency, 
            {
                lossViewIdentifier: lossView.identifier,
                aggregationMethod, 
                model, 
                country, 
                area, 
                subArea
            }
        );
    }

    getThreshold(threshold, currency, { lossView, aggregationMethod, model, country, area, subArea }) {
        return this.getMetric({metric: 'thresholds', getValue: (x) => x.threshold.value, value: threshold}, 
            currency, 
            {
                lossViewIdentifier: lossView.identifier,
                aggregationMethod, 
                model, 
                country, 
                area, 
                subArea
            }
        );
    }

    convertToBaseCurrency(value, {currency}) {
        const conversion = this.getCurrencyConversionFromBase(currency);
        if(!conversion) return null;
        return value / conversion;
    }

    getCurrencyConversionFromBase(currency) {
        if(this.baseCurrency() === currency) return 1;
        if(!this.currencies.includes(currency)) return null;
        if(!this.baseLossView()) return null;
        const targetMetric = this.getReturnPeriod(1, currency, { lossView: this.baseLossView(), aggregationMethod: 'Aep' });
        const baseMetric = this.getReturnPeriod(1, this.baseCurrency(), { lossView: this.baseLossView(), aggregationMethod: 'Aep' });
        if(!targetMetric || !baseMetric) return null;
        if(!baseMetric.values.mean || !targetMetric.values.mean) return null;
        return targetMetric.values.mean / baseMetric.values.mean;
    }

    getCurrencyConversion(fromCurrency, toCurrency) {
        const fromValue = this.getCurrencyConversionFromBase(fromCurrency);
        const toValue = this.getCurrencyConversionFromBase(toCurrency);
        if(!fromValue || !toValue) return null;
        return toValue / fromValue;
    }

    getExportOptions() {
        const output = [];
        for (let i = 0; i < this.structure.data.lossViews.length; i++) {
            const lv = this.structure.data.lossViews[i];
            if(!lv) continue;
            const nodeDef = this.node();
            if(!nodeDef || (nodeDef.data && nodeDef.data.paths && !nodeDef.data.paths[lv.identifier])) continue;
            const currencyOptions = this.currencies.length ? this.currencies : ['USD'];
            for (let c = 0; c < currencyOptions.length; c++) {
                const currency = currencyOptions[c];
                output.push({
                    networkId: this.structure.networkId,
                    networkName: this.structure.data.properties ? this.structure.data.properties.name : this.structure.networkId,
                    nodeId: this.id,
                    baseNodeId: this.baseNodeId(),
                    name: this.name,
                    perspective: this.perspective,
                    lossViewName: lv.label,
                    lossViewIdentifier: lv.identifier,
                    lossViewType: lv.type,
                    currency: currency,
                    key: `${this.name}_${this.perspective}_${lv.identifier}_${currency}`,
                    selected: false
                })
            }
        }

        return output;
        /*
        return this.exports.filter(x => !!x.sqlQueryDescriptor)
            .reduce((acc, ex) => {
                acc.push({
                    nodeId: this.id,
                    baseNodeId: this.baseNodeId(),
                    name: this.name,
                    perspective: this.perspective,
                    lossViewName: ex.lossView.label,
                    lossViewIdentifier: ex.lossView.identifier,
                    lossViewType: ex.lossView.type,
                    currency: ex.sqlQueryDescriptor.currency || 'USD',
                    uri: ex.file.uri,
                    key: `${this.name}_${this.perspective}_${ex.lossView.identifier}_${ex.sqlQueryDescriptor.currency || 'USD'}`,
                    selected: false
                });
                return acc;
            }, []);
        */
    }

    getAllNetworkExportOptions() {
        const output = [];
        const getExportOptionsForNodeArray = function(nodeResult, structure, currencies, nodes, output) {
            for (let i = 0; i < structure.data.lossViews.length; i++) {
                const lv = structure.data.lossViews[i];
                if(!lv) continue;
                for (let j = 0; j < nodes.length; j++) {
                    const nodeDef = nodes[j];
                    if(!nodeDef || (nodeDef.data && nodeDef.data.paths && !nodeDef.data.paths[lv.identifier])) continue;
                    const currencyOptions = currencies.length ? currencies : ['USD'];
                    for (let c = 0; c < currencyOptions.length; c++) {
                        const currency = currencyOptions[c];
                        const name = nodeDef && nodeDef.data ? nodeDef.data.name : null;
                        const perspective = nodeDef && nodeDef.data 
                        ? nodeDef.data.objType && nodeDef.data.objType.toLowerCase() === 'layer'
                            ? nodeDef.data.layer_type || 'ceded'
                            : 'gross'
                        : '';

                        output.push({
                            networkId: structure.networkId,
                            networkName: structure.data.properties ? structure.data.properties.name : structure.networkId,
                            nodeId: nodeDef.id,
                            baseNodeId: nodeResult.baseNodeId(nodeDef.id),
                            name: name,
                            perspective: perspective,
                            lossViewName: lv.label,
                            lossViewIdentifier: lv.identifier,
                            lossViewType: lv.type,
                            currency: currency,
                            key: `${name}_${perspective}_${lv.identifier}_${currency}`,
                            selected: false
                        })
                    }
                }
            }
        };

        getExportOptionsForNodeArray(this, this.structure, this.currencies, this.structure.inputs, output);
        getExportOptionsForNodeArray(this, this.structure, this.currencies, this.structure.layers, output);

        return output;
    }
}