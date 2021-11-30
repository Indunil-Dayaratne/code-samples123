<template>
    <div :class="{open: isOpen, caret: true}" :style="inline ? 'display: inline-block' : 'display: block'">
        <fa-icon icon="angle-right" size="lg"></fa-icon>
    </div>
</template>

<script>
    export default {
        name: 'OpenCloseCaret',
        props: {
            isOpen: {
                type: Boolean,
                default: false
            },
            inline: {
                type: Boolean,
                default: true
            }
        },
        data() {
            return {
                
            }
        },
    }
</script>

<style lang="scss" scoped>
.caret {
    transition: transform 0.25s;
    cursor: pointer;
    padding: 5px;

    &.open {
        transform: rotate(90deg);
    }
}
</style>