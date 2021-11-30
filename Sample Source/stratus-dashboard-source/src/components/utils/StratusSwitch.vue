<template>
    <div class="stratus-switch">
        <span :class="['pr-2', {'text-primary selected-option-switch': !checked}]" @click="preLabelClick">
            {{falseText}}
        </span>
        <b-checkbox :checked="checked"
            switch inline
            @change="handleChange"
            :class="{'text-primary selected-option-switch': checked}">
            {{trueText}}
        </b-checkbox>
    </div>
</template>

<script>
    export default {
        name: 'StratusSwitch',
        model: {
            prop: 'checked',
            event: 'change'
        }, 
        props: {
            checked: Boolean,
            trueText: {
                type: String,
                default: 'True'
            },
            falseText: {
                type: String,
                default: 'False'
            }
        },
        data() {
            return {
                
            }
        },
        methods: {
            handleChange(eventChecked) {
                this.$emit('change', eventChecked);
            },
            preLabelClick() {
                this.$emit('change', !this.checked);
            }
        }
    }
</script>

<style lang="scss" scoped>
.stratus-switch {
    cursor: pointer !important;
    user-select: none;

    .selected-option-switch {
        font-weight: bold;
    }

    .custom-control-label {
        cursor: pointer;

        &::before, 
        &::after {
            cursor: pointer;
        }
    } 
} 
</style>