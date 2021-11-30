<template>
    <div>
        <RelationshipTable :layerId="layerId" />
    </div>
</template>

<script>
import RelationshipTable from './RelationshipTableComponent';
    export default {
        name: 'RelationshipsPage',
        props: ['layerId'],
        components: {
            RelationshipTable
        },
        data() {
            return {
                
            }
        },
        
    }
</script>

<style lang="scss" scoped>

</style>