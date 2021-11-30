import * as LocationData from '../../../data/filter/country_area.min.json';
import * as PerilData from '../../../data/filter/perils.min.json';

const state = {
    Model: PerilData.Perils,
    Country: LocationData.Countries,
    Area: LocationData.Areas,
    filterColumnOptions: [
        'Model',
        'Country',
        'Area',
        //'Sub Area'
    ]
}

const getters = {
    getFilterOptions: (state) => (option) => {
        return state[option] || [];
    },
    getFilterObject: (state, getters) => (type, id) => {
        let options = getters.getFilterOptions(type);
        if (!options.length) return null;
        return options.find(x => {
            if (x.Model) return x.Model === id;
            if (x.GeographySid) return x.GeographySid === id;
            return false;
        });
    }
}

const mutations = {
    
}

const actions = {
    
}

export default {
    namespaced: true,
    state,
    getters,
    mutations,
    actions
}