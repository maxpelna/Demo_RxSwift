//
//  BaseViewModel.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import RxCocoa
import RxSwift
import RxFlow

protocol PBaseViewModel: Stepper {
    var isLoading: BehaviorRelay<Bool> { get }
    var error: PublishRelay<Error> { get }
    var steps: PublishRelay<Step> { get }
    var bag: DisposeBag { get }
}

class BaseViewModel: PBaseViewModel {
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishRelay<Error>()
    let steps = PublishRelay<Step>()
    let bag = DisposeBag()
}
