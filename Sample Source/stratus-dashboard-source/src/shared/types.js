export const ACCOUNT_TYPES = {
    none: {
        name: 'none'
    },
    analysis: {
        name: 'analysis',
        routeName: 'AnalysisDetails',
        plural: 'analyses',
        allowImportOnCreation: true,
        canCreateModal: false
    },
    program: {
        name: 'program',
        routeName: 'program_details',
        plural: 'programs',
        allowImportOnCreation: false,
        canCreateModal: true
    },
    getAllTypes() {
        return [
            this.analysis,
            this.program
        ];
    },
    getType(name) {
        return this.getAllTypes().find(t => t.name === name) || this.none;
    },
    getTypeFromRoute(route) {
        if(typeof(route) === 'string') return this.getAllTypes().find(t => route.includes(`/${t.name}` && !route.includes('index'))) || this.none;
        if(typeof(route) === 'object' && route && route.matched) return this.getAllTypes().find(t => route.matched.some(r => r.path === `/${t.name}`) && route.params.programRef) || this.none;
        return this.none; 
    },
    getLink({ programRef, analysisId }, analysisCheckFn) {
        if(programRef) {
            //if(analysisId && (!analysisCheckFn || (analysisCheckFn && analysisCheckFn(programRef, analysisId)))) return { name: this.analysis.routeName, params: { programRef, id: analysisId } };
            //else return { name: this.program.routeName, params: { programRef } };
            return { name: this.program.routeName, params: { programRef } };
        }
        return {};         
    }
}